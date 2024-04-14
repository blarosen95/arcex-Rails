class TransactionSerializer < BaseSerializer
  set_type 'transactions'

  # TODO: Consider the removal of `sender_id` and `recipient_id` from the base serialization since that's more of a need-to-know level of sensitivity:
  attributes(
    *%i[
      sender_id
      recipient_id
      currency
      amount
      created_at
      updated_at
    ]
  )
end
