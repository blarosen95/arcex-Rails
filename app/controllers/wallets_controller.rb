class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[show total_equity]
  def show
    serialized_wallet = WalletSerializer.new(@wallet, include: [:contents]).serializable_hash
    wallet_data = serialized_wallet[:data]
    included_data = serialized_wallet[:included]

    render json: {
      data: wallet_data,
      included: { contents: included_data }
    }
  end

  def total_equity
    render json: {
      data: {
        totalEquity: @wallet.total_balance
      }
    }
  end

  private

  def set_wallet
    @wallet = current_user&.wallet
  end
end
