require 'faker'

# Only seed if in development environment:
if Rails.env.development?
  create_first_two_users = true

  # Preparation for bulk insert:
  user_attributes = []
  wallet_attributes = []
  content_attributes = []

  if create_first_two_users
    (1..2).each do |i|
      timestamp = Time.now
      begin
        email = Faker::Internet.unique.email
      end while user_attributes.map { |user| user[:email] }.include?(email) || User.exists?(email:)

      username = Faker::Internet.unique.username

      user_attributes << {
        email:,
        username:,
        encrypted_password: '$2a$12$cl2At97lOZewOn0V93qVvuMIbDtqWocsYkEen23jWEZdaZKPEmhyC',
        confirmed_at: timestamp,
        confirmation_sent_at: timestamp, # TODO: Might need to just rm this line if it fails at all
        created_at: timestamp,
        updated_at: timestamp
      }

      wallet_attributes << {
        user_id: i,
        name: 'Default Wallet',
        currencies: CURRENCIES.map { |c| c[:code] },
        created_at: timestamp,
        updated_at: timestamp
      }

      CURRENCIES.each do |currency|
        content_attributes << {
          wallet_id: i,
          currency: currency[:code],
          balance: 0.5,
          created_at: timestamp,
          updated_at: timestamp
        }
      end
    end

    # Bulk insert users:
    User.insert_all!(user_attributes)

    # Bulk insert wallets:
    Wallet.insert_all!(wallet_attributes)

    # Bulk insert contents:
    Content.insert_all!(content_attributes)
  end
end
