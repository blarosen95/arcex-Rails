class OrdersController < ApplicationController
  before_action :set_user, only: %i[create show_order_book]
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

  def show_order_book
    asset = Asset.find(params[:asset_id])

    # TODO: At some point, I need to limit this to the MEDIAN-PRICED 100 orders (effectively excluding outliers rather than starting/ending with cheapest/priciest orders):
    book_orders = Order.where(asset:, status: :processing, locked: false, order_type: :limit_order)

    # Split book_orders into buy and sell orders:
    bids = book_orders.select { |order| order.direction == 'buy' }.sort_by(&:price).reverse
    asks = book_orders.select { |order| order.direction == 'sell' }.sort_by(&:price)

    # Initialize cumulative total hashes:
    cumulative_total_bids = { current_sum: 0 }
    cumulative_total_asks = { current_sum: 0 }

    # Serialize both bids and asks:
    bids = OrderBookOrderSerializer.new(bids, { params: { cumulative_total: cumulative_total_bids } }).serializable_hash
    asks = OrderBookOrderSerializer.new(asks, { params: { cumulative_total: cumulative_total_asks } }).serializable_hash

    # Merge together into order_book:
    order_book = { bids:, asks: }

    render json: { data: order_book }
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
    permitted = params.require(:order).permit(:direction, :price, :order_type, :asset_id, :amount)
    # Drop off `price` param if it's a market order:
    permitted.delete_if { |key, value| key == 'price' && permitted[:order_type] == 0 }
  end
end
