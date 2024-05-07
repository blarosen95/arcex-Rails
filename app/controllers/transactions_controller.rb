class TransactionsController < ApplicationController
  before_action :set_current_user_wallet, only: %i[create index sent received]

  # TODO: implement Frontend integrations (history, recents, etc) for this index method:
  def index
    as_sender = @sender_wallet.sent_transactions
    as_recipient = @sender_wallet.received_transactions

    # TODO: This should be considered as a new type: ApiModelPayloads and/or ApiModelsPayloads
    #  because we are including different types of models together in one response...
    render json: {
      data: {
        sent: TransactionSerializer.new(as_sender).serializable_hash[:data],
        received: TransactionSerializer.new(as_recipient).serializable_hash[:data]
      }
    }
  end

  def sent
    # TODO: Implement pagination (reasearch to see if anything is better than kaminari these days...):
    render json: RecipientSerializer.new(@sender_wallet.sent_transaction).serializable_hash
  end

  def received
    render json: TransactionSerializer.new(@sender_wallet.received_transactions).serializable_hash
  end

  def create
    transaction = CreateTransaction.new(@sender_wallet, permitted_params[:recipient_email], permitted_params[:amount],
                                        permitted_params[:currency]).call

    if transaction.errors.any?
      render json: {
        status: { message: transaction.errors.full_messages.join(', ') }
      }, status: :unprocessable_entity
    else
      render json: TransactionSerializer.new(transaction).serializable_hash
    end
  end

  private

  def set_current_user_wallet
    # ? TODO: Probably should rescue error and return a meaningful message via errors.add if it can't find this wallet (indicative of user creation failures)
    @sender_wallet = current_user.wallet
  end

  def permitted_params
    # ! TODO: Eventually, we won't just enable sending to recipients based on their email:
    # params.require(:transaction).permit(:sender_wallet_id, :recipient_email, :amount, :currency)
    # ! TODO: For now, we're building so that users have just one wallet, eventually they will likely be able to have multiple wallets per user, but for now:
    params.require(:transaction).permit(:recipient_email, :amount, :currency)
  end
end
