class ContentSerializer < BaseSerializer
    set_type 'contents'

    attributes(
        *%i[
            currency
            balance
            created_at
            updated_at
        ]
    )
end