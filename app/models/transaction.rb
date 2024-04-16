class Transaction < ApplicationRecord
  belongs_to :sender, class_name: 'Wallet'
  belongs_to :recipient, class_name: 'Wallet'

  enum status: { processing: 0, complete: 1, errored: 2 }

  validates :currency, presence: true
  # TODO: Also, validate that the amount is within the wallet's Content balance for the given currency:
  validates :amount, numericality: true
  validates :sender, :recipient, presence: true

  validate :sender_and_recipient_different?
  validate :sufficient_balance?

  after_create :process_transaction!

  def process_transaction!
    ActiveRecord::Base.transaction do
      if perform_aml_checks && deduct_sender_balance! && add_recipient_balance!
        update!(status: :complete)
      else
        update!(status: :errored)
        # TODO: Implement our safety/sanity checks here (i.e. ensuring none of the currency is transferred at all)
      end
    end
  rescue StandardError => _e
    update!(status: :errored)
    puts 'filter here: ERROR RESCUE'
    # TODO: Log the error & remove the underscore prefix from `e` to document that it shouldn't allow useless assignment
    # TODO: Implement our safety/sanity checks here
  end

  # TODO: This is not their name... It's also irrelevant for transactions that occur partially outside of ArcEx:
  def recipient_name
    recipient.user.username
  end

  private

  ## Validators

  def sender_and_recipient_different?
    errors.add(:sender, 'cannot be the same as the recipient') if sender.hashid == recipient.hashid
  end

  def sufficient_balance?
    return unless sender.present? && recipient.present?

    sender_content = sender.contents.find_by(currency:)

    errors.add(:amount, "exceeds sender's balance") unless sender_content&.balance&.>= amount.to_f
  end

  def perform_aml_checks
    # Implement AML check logic here
    # Return true if checks pass, false otherwise
    # TODO: For now, return true. But revisit to implement AML logic once at least an MVP-level approach is known
    true
  end

  def deduct_sender_balance!
    # Deduct amount from sender's balance
    # Ensure this change is immediately reflected to prevent overdrafts (i.e maybe implement a concern of LedgerBalance)
    # Return true if successful, false otherwise
    content = sender.contents.find_by(currency:)
    remaining_balance = content.balance.to_f - amount.to_f
    content.update!(balance: remaining_balance)
  end

  def add_recipient_balance!
    # Add amount to recipient's balance
    # This should only happen if AML checks passed and the sender's balance was successfully deducted
    # Return true if successful, false otherwise
    content = recipient.contents.find_by(currency:)
    new_balance = content.balance.to_f + amount.to_f
    content.update!(balance: new_balance)
  end
end
