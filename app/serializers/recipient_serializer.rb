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
