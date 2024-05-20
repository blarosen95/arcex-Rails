class Order < ApplicationRecord
  belongs_to :user
  belongs_to :asset

  # An order that is fully filled in 1 trade will relate to just 1 trade, but orders can have many trades for partials:
  has_many :immediate_trades, class_name: 'Trade', foreign_key: 'immediate_order_id'
  has_many :book_trades, class_name: 'Trade', foreign_key: 'book_order_id'

  # TODO: Eventually, `reserved` type will be replaced with real types as a feature (i.e. stop loss, take profit, etc.):
  enum order_type: %i[market_order limit_order reserved_order_type]

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
  enum direction: %i[buy sell reserved_direction]

  before_validation :set_default_amount_remaining, on: :create

  validates :amount, numericality: true
  validates :order_type, :status, :direction, presence: true

  def process_order!
    ActiveRecord::Base.transaction do
      OrderBook.new(self).call
    end
  end

  def opposite_direction
    buy? ? 'sell' : 'buy'
  end

  def trades
    (immediate_trades + book_trades).sort_by(&:created_at)
  end

  # TODO: Decide which of these actually needs to be private (CRITICALLY IMPORTANT!):
  # private

  # This method should calculate the fee based on the direction and the user's rolling volume:
  def fee
    # TODO: But for now, let's just return 0.00 for both directions:
    if buy?
      0.00
    elsif sell?
      0.00
    end
  end

  def set_default_amount_remaining
    self.amount_remaining ||= amount
  end

  def with_lock!
    update!(locked: true)

    transaction do
      lock!
      yield self if block_given?
    ensure
      update!(locked: false)
    end
  end

  def fully_filled?
    amount_remaining.zero?
  end

  # This method is intended to be called by the Trade model after a trade is executed
  # TODO: It could use a better name for sure:
  def update_status_after_trade!
    update!(status: fully_filled? ? :processed : :processing)
  end
end
