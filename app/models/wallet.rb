class Wallet < ApplicationRecord
  belongs_to :user

  has_many :contents, dependent: :destroy
  has_many :sent_transactions, class_name: 'Transaction', foreign_key: 'sender_id'
  has_many :received_transactions, class_name: 'Transaction', foreign_key: 'recipient_id'

  validate :currencies_are_supported

  after_create :create_associations

  def total_balance
    contents.map(&:usdt_value).sum
  end

  private

  def currencies_are_supported
    currencies.each do |currency|
      unless CURRENCIES.any? { |c| c[:code] == currency }
        errors.add(:currencies, "#{currency} is not a supported currency")
      end
    end
  end

  # ? Every wallet has many `content` records, one for each supported currency
  def create_contents
    CURRENCIES.each do |currency|
      wallet_content = contents.create(currency: currency[:code], balance: 0.0)
      # TODO: Replace below with above when not testing Wallet UI/UX:
      # wallet_content = contents.create(currency: currency[:code], balance: 0.5)

      unless wallet_content.save
        Rails.logger.error "Contents could not be created for wallet #{id}: #{contents.errors.full_messages.join(', ')}"
      end
    end
  end

  def create_associations
    create_contents
  end
end
