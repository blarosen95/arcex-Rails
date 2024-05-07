class User < ApplicationRecord
  has_one :wallet, dependent: :destroy

  # has_many :sent_transactions, through: :wallet # TODO Implement the polymorphic Transaction assocations...

  has_many :orders
  has_many :trades, through: :orders

  after_create :create_associations

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  private

  def create_wallet
    wallet = build_wallet(user: self, name: 'Default Wallet')
    return if wallet.save

    Rails.logger.error "Wallet could not be created for user #{id}: #{wallet.errors.full_messages.join(', ')}"
  end

  def create_associations
    create_wallet
  end
end
