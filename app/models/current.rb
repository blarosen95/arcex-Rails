class Current < ActiveSupport::CurrentAttributes
    attribute(*%i[user authentication session])

    attribute(
        *%i[
            user_agent
            remote_ip
            controller
            action
            method_name
            exception
            session_auth_id_short
        ],
    )
end