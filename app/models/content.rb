class Content < ApplicationRecord
  belongs_to :wallet

  validates :currency, presence: true
  validates :balance, numericality: true
end
