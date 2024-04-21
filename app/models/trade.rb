class Trade < ApplicationRecord
  belongs_to :order
  belongs_to :user, through: :order

  enum status: %i[pending queued filled errored]

  validates :executed_price, :executed_amount, :fee, numericality: true
  validates :status, presence: true

  after_create :process_trade!

  def process_trade!
    ActiveRecord::Base.transaction do
      # TODO: power through for now for a basic MVP, but way more thought is needed regarding execution & lifecycles:
      # TODO: For one, we should not await `execute_trade!`'s completion before upstream is aware of this trade object:
      if update!(status: :queued) && execute_trade!
        update!(status: :filled)
      else
        update!(status: :errored)
        errors.add(:base, 'Trade could not be processed')
      end
    end
  end

  private

  def fully_filled?
    order.amount == executed_amount && status == 'filled'
  end

  def partially_filled?
    executed_amount.positive? && status == 'filled'
  end
end
