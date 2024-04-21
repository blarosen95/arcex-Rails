class AssetSerializer < BaseSerializer
  set_type 'assets'

  attributes(
    *%i[
      code
      name
      created_at
      updated_at
    ],
    :is_fiat,
    :current_value
  )

  # Custom attributes to include in the serialization
  attribute :is_fiat, &:fiat?
  attribute :current_value, &:current_value
end
