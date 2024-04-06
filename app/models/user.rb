class User < ApplicationRecord
  has_one :wallet, dependent: :destroy

  after_create :create_associations

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  private

  def create_wallet
    wallet = build_wallet(user: self, currencies: CURRENCIES.map { |c| c[:code] }, name: "Default Wallet")
    unless wallet.save
      Rails.logger.error "Wallet could not be created for user #{id}: #{wallet.errors.full_messages.join(", ")}"
    end
  end

  def create_associations
    create_wallet
  end
end
