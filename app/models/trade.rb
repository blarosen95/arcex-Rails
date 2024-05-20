class Trade < ApplicationRecord
  belongs_to :immediate_order, class_name: 'Order'
  belongs_to :book_order, class_name: 'Order'

  enum status: %i[pending completed errored]

  before_validation :set_default_fee, on: :create

  validates :execution_price, :execution_amount, :immediate_order_fee, :book_order_fee, numericality: true
  validates :status, presence: true

  validate :users_distinct?

  def users_distinct?
    return if immediate_order.user_id != book_order.user_id

    errors.add(:base, 'Trades between the same user are not allowed.')
  end

  # TODO: Determine which of the following methods should ACTUALLY be private:
  # private

  def set_default_fee
    self.immediate_order_fee = immediate_order.fee
    self.book_order_fee = book_order.fee
  end

  def execute_trade!
    # So, first we need to determine the buyer and the seller:
    buyer_order = immediate_order.buy? ? immediate_order : book_order
    seller_order = immediate_order.sell? ? immediate_order : book_order

    # Next, we need to calculate the fees for both orders:
    buyer_fee = buyer_order.fee
    seller_fee = seller_order.fee

    # Next, calculate total cost for the buyer, and total revenue for the seller:
    buyer_total_cost = (execution_price * execution_amount) + buyer_fee
    seller_total_revenue = (execution_price * execution_amount) - seller_fee

    # Now, update the balance for the buyer to prevent race conditions causing overspending from other processing trades:
    buyer_wallet = buyer_order.user.wallet
    seller_wallet = seller_order.user.wallet

    # TODO: CRITICAL: Temporary, very rough, implementation of a definition for the `fiat_asset` and `crypto_asset` variables. This is being done just to get Carl a demo video before the MVP is done:
    fiat_asset = Asset.find_by(fiat: true)
    crypto_asset = buyer_order.asset

    buyer_fiat_content = buyer_wallet.contents.find_by(asset: fiat_asset)
    seller_fiat_content = seller_wallet.contents.find_by(asset: fiat_asset)

    # Calculate the new fiat blaances and assign them:
    new_buyer_fiat_balance = buyer_fiat_content.balance - buyer_total_cost
    new_seller_fiat_balance = seller_fiat_content.balance + seller_total_revenue
    buyer_fiat_content.assign_attributes(balance: new_buyer_fiat_balance)
    seller_fiat_content.assign_attributes(balance: new_seller_fiat_balance)

    # Fetch crypto asset contents for both buyer and seller
    buyer_crypto_content = buyer_wallet.contents.find_by(asset: crypto_asset)
    seller_crypto_content = seller_wallet.contents.find_by(asset: crypto_asset)

    # Calculate the new crypto balances and assign them:
    new_buyer_crypto_balance = buyer_crypto_content.balance + execution_amount
    new_seller_crypto_balance = seller_crypto_content.balance - execution_amount
    buyer_crypto_content.assign_attributes(balance: new_buyer_crypto_balance)
    seller_crypto_content.assign_attributes(balance: new_seller_crypto_balance)

    # Now, save all of those changes to the database:
    buyer_fiat_content.save!
    seller_fiat_content.save!
    buyer_crypto_content.save!
    seller_crypto_content.save!

    self.status = :completed
    save!
  end
end
