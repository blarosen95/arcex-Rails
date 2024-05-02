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

  before_validation :set_default_amount_remaining, on: :create

  validates :currency, presence: true
  validates :amount, numericality: true
  validates :order_type, :status, :direction, presence: true

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

  def set_default_amount_remaining
    self.amount_remaining ||= amount
  end

  def opposite_direction
    direction == 'buy' ? 'sell' : 'buy'
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
    amount_remaining.zero? && status == 'processed'
  end
end
