class OrdersController < ApplicationController
  before_action :set_user, only: %i[create]
  before_action :set_asset, only: %i[create]

  def create
    order = build_order
    # The order won't need to be truly locked yet as it's not saved to DB, so keep going with Order Book procedures:

    if order.errors.any?
      render json: {
        status: { message: order.errors.full_messages.join(', ') }
      }, status: :unprocessable_entity and return
    end

    render json: OrderSerializer.new(order).serializable_hash

    order.process_order!
  end

  private

  def set_user
    @user = current_user
  end

  # TODO: Decide between error responses of: 404, 422 or 400:
  def set_asset
    @asset = Asset.find(permitted_params[:asset_id])
  end

  def build_order
    Order.new(
      user: @user,
      asset: @asset,
      direction: permitted_params[:direction],
      amount: permitted_params[:amount],
      amount_remaining: permitted_params[:amount],
      price: permitted_params[:price],
      order_type: permitted_params[:order_type]
    )
  end

  def permitted_params
    params.require(:order).permit(:direction, :price, :order_type, :asset_id, :amount)
  end
end
