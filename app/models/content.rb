class Content < ApplicationRecord
  belongs_to :wallet

  validates :currency, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def usdt_value
    # ! TODO: For right now, values are hardcoded in CURRENCIES. So let's look up value from there for now:
    currency = CURRENCIES.find { |c| c[:code] == self.currency }
    currency[:current_value] * balance
  end

  def full_currency_name
    currency = CURRENCIES.find { |c| c[:code] == self.currency }
    currency[:name]
  end

  def fiat?
    currency = CURRENCIES.find { |c| c[:code] == self.currency }
    currency[:is_fiat]
  end
end
