class CreateTransaction
  include ActiveModel::Model

  attr_reader :sender, :recipient_email, :amount, :currency
  attr_accessor :recipient

  def initialize(sender, recipient_email, amount, currency)
    super() # triggers ActiveModel::Model's intialize method to set up @errors
    @sender = sender
    @recipient_email = recipient_email
    @amount = amount
    @currency = currency
  end

  def call
    set_recipient
    return self unless recipient

    transaction = Transaction.new(
      sender:,
      recipient:,
      amount:,
      currency:
    )

    transaction.save if transaction.valid?

    transaction
  end

  private

  def set_recipient
    self.recipient = User.find_by_email(recipient_email)&.wallet
    # TODO: Consider the risks of introducing email-based user enumeration via the following statement:
    errors.add(:recipient, 'not found') unless recipient.present?
  end
end
