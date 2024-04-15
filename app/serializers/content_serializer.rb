class ContentSerializer < BaseSerializer
  set_type 'contents'

  attributes(
    *%i[
      currency
      balance
      created_at
      updated_at
    ],
    :usdt_value
  )

  # Custom attributes to include in the serialization
  attribute :usdt_value, &:usdt_value
  attribute :full_currency_name, &:full_currency_name
  attribute :is_fiat, &:fiat?
end
