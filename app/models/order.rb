class Order < ApplicationRecord
  belongs_to :user

  # An order that is fully filled in 1 trade will relate to just 1 trade, but orders can have many trades for partials:
  has_many :trades

  # TODO: Might be smart to belongs_to :asset instead of a currency attribute at all, just allow it in the params for creating orders

  # TODO: Eventually, `reserved` type will be replaced with real types as a feature (i.e. stop loss, take profit, etc.):
  enum order_type: %i[market limit reserved]

  # Loose status spec:
  # - `pending` is when order is first created in Active Record
  # - `processing` is when the order has been validated but we have yet to create a Trade and add to Order Book
  # - `processed` is when the order is in the order book and a valid Trade object has been created
  # - `errored` is when the order has failed validation or processing as either an Order/Trade object or in Order Book
  enum status: %i[pending processing processed errored]

  # Loose direction spec:
  # - `buy` is when an order is placed to purchase an asset
  # - `sell` is when an order is placed to sell an asset
  # - `reserved` will be replaced with features such as margin trading
  enum direction: %i[buy sell reserved]

  validates :currency, presence: true
  validates :amount, numericality: true
  validates :order_type, :status, :direction, presence: true

  # And we should also run some custom validators, such as ensuring the user has enough balance to place the order:
  validate :sufficient_balance?, on: :create

  # This hook's method will queue in order book and create a Trade object as well:
  after_create :process_order!

  def process_order!
    ActiveRecord::Base.transaction do
      # TODO: Use `build_wallet`/similar so that I can leverage built-in Active Record code:
      if create_trade! && update!(status: :processing)
        # TODO: Queue the order in the order book service and update the order status to `processed` if successful
      end
    rescue StandardError => e
      puts "filter here: ERROR RESCUE: #{e.inspect}"
      update!(status: :errored)
      errors.add(:base, 'Order could not be processed')
    end
  end

  private

  def sufficient_balance?
    return if sufficient_balance_for_direction?

    errors.add(:amount, "exceeds user's balance")
  end

  def sufficient_balance_for_direction?
    currency = direction == 'buy' ? 'USD' : self.currency
    balance = current_user.wallet.contents.find_by(currency:)&.balance.to_f

    balance >= amount_to_spend
  end

  def amount_to_spend
    direction == 'buy' ? amount.to_f * price.to_f : amount.to_f
  end
end
