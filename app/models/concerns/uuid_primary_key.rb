#! TODO: Refactor away from MySQLBinUUID to whatever we need to use for PostgreSQL
module UuidPrimaryKey
  extend ActiveSupport::Concern

  included do
    attribute :id, MySQLBinUUID::Type.new
    before_create :ensure_id
    validate :forbid_changing_id, on: :update
  end

  def forbid_changing_id
    errors.add :id, I18n.t('models.concerns.uuid-primary-key.forbid-changing-id') if id_changed?
  end

  def ensure_id
    self.id ||= SecureRandom.uuid
  end

  def hashid
    self.id
  end

  class_methods do
    def find_by_id(*args)
      super
    rescue MySQLBinUUID::InvalidUUID
      nil
    end

    def hashid(id)
      id
    end
  end
end
