class Content < ApplicationRecord
  belongs_to :wallet
  belongs_to :asset

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def currency
    asset.code
  end

  def usdt_value
    asset.current_value * balance
  end

  def full_currency_name
    asset.name
  end

  def fiat?
    asset.fiat?
  end

  private

  def asset_hashid
    asset.hashid
  end
end
