class UserSerializer < BaseSerializer
  set_type 'users'

  attributes(
    *%i[
      email
      username
      is_admin
      created_at
      sign_in_count
    ]
  )
end
