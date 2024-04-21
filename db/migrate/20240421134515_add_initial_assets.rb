class AddInitialAssets < ActiveRecord::Migration[7.1]
  def change
    # Check if record exists before adding to ensure idempotency
    Asset.find_or_create_by(code: 'USD') do |asset|
      asset.name = 'United States Dollar'
      asset.fiat = true
    end
    Asset.find_or_create_by(code: 'BTC') do |asset|
      asset.name = 'Bitcoin'
      asset.fiat = false
    end
    Asset.find_or_create_by(code: 'ETH') do |asset|
      asset.name = 'Ethereum'
      asset.fiat = false
    end
  end
end
