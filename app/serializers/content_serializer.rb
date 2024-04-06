class ContentSerializer < BaseSerializer
    set_type 'contents'

    attributes(
        *%i[
            currency
            balance
            created_at
            updated_at
        ],
        :usdt_value
    )

    attribute :usdt_value do |object|
        object.usdt_value
    end
end