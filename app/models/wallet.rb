class Wallet < ApplicationRecord
    belongs_to :user
    has_many :contents, dependent: :destroy
    validate :currencies_are_supported

    after_create :create_associations

    private

    def currencies_are_supported
        currencies.each do |currency|
            unless CURRENCIES.any? { |c| c[:code] == currency }
                errors.add(:currencies, "#{currency} is not a supported currency")
            end
        end
    end

    #? Every wallet has many `content` records, one for each supported currency
    def create_contents
        CURRENCIES.each do |currency|
            wallet_content = contents.create(currency: currency[:code], balance: 0.0)

            Rails.logger.error "Contents could not be created for wallet #{id}: #{contents.errors.full_messages.join(", ")}" unless wallet_content.save
        end
    end

    def create_associations
        create_contents
    end
end
