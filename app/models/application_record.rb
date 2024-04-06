class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.connects_to database: { writing: :primary, reading: :primary_replica }
  self.include_root_in_json = true

  def self.hashid_instance
    Hashids.v2_instance(table_name: self.table_name)
  end

  def self.hashid(id)
    return id if self.is_hashid?(id)
    self.hashid_instance.encode(id.to_s) if id.present?
  end

  def self.fetch_hashid(id)
    return unless id.present?
    return id if id.to_s.length == 22 && self.parse_id(id).present?
    int_id = nil
    int_id = Hashids.v1_hashid_decode(id).to_i unless /^[0-9]+$/.match(id.to_s)
    int_id = id.to_i unless int_id&.positive?
    return self.hashid(int_id) if int_id&.positive?
    nil
  end

  def hashid
    self.class.hashid(self.id)
  end

  def self.is_hashid?(x)
    !!(
      (x.to_s.length == 22) &&
        (
          begin
            self.hashid_instance.decode(x)&.first
          rescue StandardError
            nil
          end
        )
    )
  end

  def self.parse_id(hash_id, require_hashid: false, raise_if_missing: false)
    if (hash_id.to_s.length == 22 || require_hashid || raise_if_missing) && !self.ancestors.include?(UuidPrimaryKey)
      raise NotFoundError if (require_hashid || raise_if_missing) && hash_id.to_s.length != 22
      rtn = self.hashid_instance.decode(hash_id)&.first
      raise NotFoundError if (require_hashid || raise_if_missing) && rtn.blank?
      rtn
    else
      hash_id
    end
  end

  def self.parse_ids(hash_ids, require_hashid: false, raise_if_missing: false)
    if hash_ids.first.to_s.length == 22 || require_hashid || raise_if_missing
      hash_ids =
        hash_ids.map do |i|
          raise NotFoundError if (require_hashid || raise_if_missing) && i.to_s.length != 22
          self.hashid_instance.decode(i)&.first
        end
      raise NotFoundError if (require_hashid || raise_if_missing) && hash_ids.any?(&:blank?)
      hash_ids
    else
      hash_ids
    end
  end

  def self.find(*args, require_hashid: false)
    if block_given?
      super(*args)
    else
      x =
        if args.first.is_a?(Array)
          args.first.map { |i| self.parse_id(i, require_hashid: require_hashid) }
        else
          self.parse_id(args.first, require_hashid: require_hashid)
        end
      super(x)
    end
  end

  def self.created_after(t)
    self.where(created_at: t..Time.now)
  end
end

class ActiveRecord::Relation
  def find(*args, require_hashid: false)
    if block_given?
      super(*args)
    else
      x =
        if args.first.is_a?(Array)
          args.first.map do |i|
            self.model.respond_to?(:parse_id) ? self.model.parse_id(i, require_hashid: require_hashid) : i
            # self.model.parse_id(i, require_hashid: require_hashid)
          end
        else
          m = self.model
          m.respond_to?(:parse_id) ? m.parse_id(args.first, require_hashid: require_hashid) : args.first
          # self.model.parse_id(args.first, require_hashid: require_hashid)
        end
      super(x)
    end
  end
end
