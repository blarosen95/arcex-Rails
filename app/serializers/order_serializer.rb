class OrderSerializer < BaseSerializer
  set_type 'orders'

  attributes(
    *%i[
      direction
      price
      amount
      amount_remaining
      order_type
      status
      created_at
      updated_at
    ],
    # :currency,
    :asset_id
  )

  # Custom attributes to include in the serialization
  # TODO: Fix both of the methods that should be used here:
  # attribute :currency, &:currency
  attribute :asset_id, &:asset_id
end
