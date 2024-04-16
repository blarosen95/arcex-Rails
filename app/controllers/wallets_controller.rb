class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[show total_equity]
  def show
    # TODO: For rn, users will only have one wallet, so find the wallet based on current user ownership
    # @wallet = Wallet.find(params[:id])

    serialied_wallet = WalletSerializer.new(@wallet, include: [:contents]).serializable_hash
    wallet_data = serialied_wallet[:data]
    included_data = serialied_wallet[:included]

    render json: {
      data: wallet_data,
      included: { contents: included_data }
    }
  end

  def total_equity
    render json: {
      data: {
        total_equity: @wallet.total_balance
      }
    }
  end

  private

  def set_wallet
    @wallet = current_user&.wallet
  end
end
