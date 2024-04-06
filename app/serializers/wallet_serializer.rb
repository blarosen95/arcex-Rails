class WalletSerializer < BaseSerializer
  set_type 'wallets'

  attributes(
    *%i[
      name
      currencies
      created_at
      updated_at
    ],
    :total_balance
  )

  # Assocations to include in the serialization:
  has_many :contents

  # Custom attributes to include in the serialization:
  attribute :total_balance, &:total_balance
end
