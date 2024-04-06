class WalletSerializer < BaseSerializer
  set_type 'wallets'

  attributes(
    *%i[
      name
      currencies
      created_at
      updated_at
    ]
  )

  # Assocations to include in the serialization:
  has_many :contents
end
