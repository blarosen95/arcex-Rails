class TransactionSerializer < BaseSerializer
  set_type 'transactions'

  attributes(
    *%i[
      asset_id
      amount
      created_at
      updated_at
    ]
  )
end
