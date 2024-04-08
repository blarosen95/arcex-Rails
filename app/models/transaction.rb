class Transaction < ApplicationRecord
  belongs_to :sender
  belongs_to :recipient

  validates :currency, presence: true
  # TODO: Also, validate that the amount is within the wallet's Content balance for the given currency:
  validates :amount, numericality: true
  validates :sender, :recipient, presence: true

  validate :sender_and_recipient_different?
  validate :sufficient_balance?

  private

  def sender_and_recipient_different?
    errors.add(:sender, "cannot be the same as the recipient") if sender.hashid == recipient.hashid
  end

  def sufficient_balance?
    return unless sender.present? && recipient.present?

    sender_content = sender.contents.find_by(currency: currency)

    errors.add(:amount, "exceeds sender's balance") unless sender_content&.balance >= amount
  end
end
