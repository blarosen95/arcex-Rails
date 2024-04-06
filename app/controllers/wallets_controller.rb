class WalletsController < ApplicationController
  def show
    # @wallet = Wallet.find(params[:id])
    #! TODO: For rn, users will only have one wallet, so find the wallet based on current user ownership:
    @wallet = current_user.wallet

    serialied_wallet = WalletSerializer.new(@wallet, include: [:contents]).serializable_hash
    wallet_data = serialied_wallet[:data]
    included_data = serialied_wallet[:included]

    render json: {
        data: wallet_data,
        included: { contents: included_data }
    }
  end

#   def new
#     @wallet = Wallet.new
#   end

#   def create
#     @wallet = Wallet.new(wallet_params)

#     if @wallet.save
#       redirect_to @wallet
#     else
#       render :new
#     end
#   end

#   private

#   def wallet_params
#     params.require(:wallet).permit(:name, :balance)
#   end
end