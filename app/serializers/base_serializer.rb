class BaseSerializer
  include JSONAPI::Serializer

  set_id :hashid
  set_key_transform :camel_lower

  def self.exclude_attributes(_record, _params)
    []
  end

  def self.exclude_relationships(_record, _params)
    []
  end

  # def self.attributes_hash(record, fieldset = nil, params = {})
  #     attributes =
  #         self.attributes_to_serialize.reject do
  #             self.exclude_attributes(record, params).map { |a| a.to_s.gsub('_', '-').to_sym }.include?(_1.to_sym)
  #         end
  #     attributes = attributes.slice(*fieldset) if fieldset.present?
  #     attributes = {} if fieldset == []

  #     attributes.each_with_object({}) { |(_k, attribute), hash| attribute.serialize(record, params, hash) }
  # end
  # TODO: If I run into issues with serialized payloads, remember the above wasn't included when fixing enum serializations with below:
  def self.attributes_hash(record, fieldset = nil, params = {})
    raw_attributes = super

    enums = record.class.defined_enums
    raw_attributes.transform_keys! { |key| key.to_s.underscore }
    raw_attributes.each do |key, value|
      raw_attributes[key] = record.read_attribute_before_type_cast(key) if enums.key?(key)
    end

    if transform_method == %i[camelize lower]
      raw_attributes.transform_keys! do |key|
        key.to_s.camelcase(:lower).to_sym
      end
    end

    raw_attributes
  end

  def self.relationships_hash(record, relationships = nil, fieldset = nil, includes_list = nil, params = {})
    relationships =
      (relationships || relationships_to_serialize || []).reject do
        exclude_relationships(record, params).include?(_1.to_sym)
      end
    super(record, relationships, fieldset, includes_list, params)
  end
end
