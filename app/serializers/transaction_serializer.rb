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

class RecipientSerializer < BaseSerializer
  set_type 'recipients'

  attributes(
    *%i[
      recipient_id
      created_at
      updated_at
    ],
    :recipient_name
  )

  # Custom attributes to include in the serialization:
  attribute :recipient_name, &:recipient_name
end

class SenderSerializer < BaseSerializer
  set_type 'senders'

  attributes(
    *%i[
      currency
      amount
      created_at
      updated_at
    ]
  )

  # Custom attributes to include in the serialization:
  attribute :recipient_name, &:recipient_name
end
