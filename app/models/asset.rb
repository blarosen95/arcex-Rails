class Asset < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :fiat, inclusion: { in: [true, false] }

  def current_value
    # TODO: For now, Single Source of Truth for pricing is in CURRENCIES constant (initializes from `currencies.yml`):
    currency = CURRENCIES.find { |c| c[:code] == code }
    currency[:current_value]
  end

  def fiat?
    fiat
  end
end
