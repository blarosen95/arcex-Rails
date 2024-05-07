class ContentSerializer < BaseSerializer
  set_type 'contents'

  attributes(
    *%i[
      balance
      created_at
      updated_at
    ],
    :currency,
    :usdt_value
  )

  # Custom attributes to include in the serialization
  attribute :currency, &:currency
  attribute :usdt_value, &:usdt_value
  attribute :full_currency_name, &:full_currency_name
  attribute :is_fiat, &:fiat?
  attribute :asset_id, &:asset_hashid
end
