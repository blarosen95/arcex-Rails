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
