class Trade < ApplicationRecord
  belongs_to :immediate_order, class_name: 'Order'
  belongs_to :book_order, class_name: 'Order'

  enum status: %i[pending completed errored]

  validates :execution_price, :execution_amount, :fee, numericality: true
  validates :status, presence: true

  validate :users_distinct?

  def users_distinct?
    return if immediate_order.user_id != book_order.user_id

    errors.add(:base, 'Trades between the same user are not allowed.')
  end

  private

  def execute_trade!
    # So, first we need to determine the buyer and the seller:
    buyer_order = immediate_order.direction_buy? ? immediate_order : book_order
    seller_order = immediate_order.direction_sell? ? immediate_order : book_order

    # TODO: Implement a `fee` method in the Order model:
    # Next, we need to calculate the fees for both orders:
    buyer_fee = buyer_order.fee
    seller_fee = seller_order.fee

    # Next, calculate total cost for the buyer, and total revenue for the seller:
    buyer_total_cost = (execution_price * execution_amount) + buyer_fee
    seller_total_revenue = (execution_price * execution_amount) - seller_fee

    # Now, update the balance for the buyer to prevent race conditions causing overspending from other processing trades:
    buyer_wallet = buyer_order.user.wallet
    # TODO: Will need to finish refactoring this model to relate to assets:
    # TODO: Will also need to finish refactoring the content model to validate non-negative balances:
    buyer_wallet.contents.find_by(asset: fiat_asset).decrement(:balance, buyer_total_cost)

    # If we're here, then the buyer can afford the entire transaction cost, so we can update the seller's balance too:
    seller_wallet = seller_order.user.wallet
    seller_wallet.contents.find_by(asset: fiat_asset).increment(:balance, seller_total_revenue)

    # Now, ensure the asset is transferred from the seller to the buyer:
    seller_wallet.contents.find_by(asset: crypto_asset).decrement(:balance, execution_amount)
    buyer_wallet.contents.find_by(asset: crypto_asset).increment(:balance, execution_amount)

    # Finally, update both wallets' contents:
    buyer_wallet.save!
    seller_wallet.save!
  end
end
