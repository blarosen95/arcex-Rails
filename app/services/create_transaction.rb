class CreateTransaction
  include ActiveModel::Model

  attr_reader :sender, :recipient_email, :amount, :asset_id
  attr_accessor :recipient, :asset

  def initialize(sender, recipient_email, amount, asset_id)
    super() # triggers ActiveModel::Model's intialize method to set up @errors
    @sender = sender
    @recipient_email = recipient_email
    @amount = amount
    @asset_id = asset_id
  end

  def call
    set_recipient
    set_asset
    return self unless recipient

    transaction = Transaction.new(
      sender:,
      recipient:,
      asset:,
      amount:
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

  def set_asset
    self.asset = Asset.find(asset_id)
    errors.add(:asset, 'not found') unless asset.present?
  end
end
