class OrdersController < ApplicationController
  # TODO: The following is probably a good idea as it shouldn't NEED to be auth-walled:
  skip_before_action :authenticate_user!, only: %i[show_order_book]
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

  def show_order_book
    asset_id = Asset.parse_id(params[:asset_id])
    counts = (params[:count] || 100).to_i
    order_grouping_threshold = (params[:threshold] || 0.01).to_f

    # TODO: At some point, I need to limit this to the MEDIAN-PRICED 100 orders (effectively excluding outliers rather than starting/ending with cheapest/priciest orders):
    bids = Order.where(asset_id:, status: :processing, locked: false, order_type: :limit_order, direction: :buy)
                .order(price: :desc, created_at: :asc)
                .limit(counts)

    asks = Order.where(asset_id:, status: :processing, locked: false, order_type: :limit_order, direction: :sell)
                .order(price: :asc, created_at: :asc)
                .limit(counts)

    # Group orders by price threshold:
    grouped_bids = group_orders_by_price_threshold(bids, order_grouping_threshold)
    grouped_asks = group_orders_by_price_threshold(asks, order_grouping_threshold)

    # Initialize cumulative total hashes:
    cumulative_total_bids = { current_sum: 0 }
    cumulative_total_asks = { current_sum: 0 }

    # Serialize both bids and asks:
    bids = OrderBookOrderSerializer.new(grouped_bids,
                                        { params: { cumulative_total: cumulative_total_bids } }).serializable_hash
    asks = OrderBookOrderSerializer.new(grouped_asks,
                                        { params: { cumulative_total: cumulative_total_asks } }).serializable_hash

    # Merge together into order_book:
    order_book = { bids:, asks: }

    render json: { data: order_book }
  end

  private

  def set_user
    @user = current_user || render_unauthorized! and return
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

  def group_orders_by_price_threshold(orders, threshold)
    grouped_orders = []
    current_group = []

    orders.each do |order|
      if current_group.empty?
        current_group << order
      else
        last_order = current_group.last
        if within_price_threshold?(last_order.price, order.price, threshold)
          current_group << order
        else
          grouped_orders << merge_order_group(current_group)
          current_group = [order]
        end
      end
    end
    grouped_orders << merge_order_group(current_group) unless current_group.empty?
    grouped_orders
  end

  def within_price_threshold?(price1, price2, threshold)
    (price1 - price2).abs / [price1, price2].min <= threshold
  end

  def merge_order_group(order_group)
    return order_group.first if order_group.size == 1

    merged_order = order_group.first.dup
    merged_order.amount = order_group.sum(&:amount)
    merged_order.amount_remaining = order_group.sum(&:amount_remaining)
    merged_order
  end
end
