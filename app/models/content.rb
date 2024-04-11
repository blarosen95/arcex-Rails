class Content < ApplicationRecord
  belongs_to :wallet

  validates :currency, presence: true
  validates :balance, numericality: true

  def usdt_value
    # ! TODO: For right now, values are hardcoded in CURRENCIES. So let's look up value from there for now:
    currency = CURRENCIES.find { |c| c[:code] == self.currency }
    currency[:current_value] * balance
  end
end
