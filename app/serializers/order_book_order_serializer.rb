class OrderBookOrderSerializer < BaseSerializer
  set_type 'orders'

  attributes(
    *%i[
      price
      amount
      created_at
      updated_at
    ]
  )

  # Custom attributes to include in the serialization
  attribute :total do |order, params|
    current_sum = params[:cumulative_total][:current_sum]
    total = current_sum + order.amount
    params[:cumulative_total][:current_sum] = total
    total
  end
end
