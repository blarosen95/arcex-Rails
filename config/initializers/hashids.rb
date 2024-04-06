class Hashids
    def self.v1_instance
        @@v1_instance ||= Hashids.new(HASH_ID_SALT)
    end

    def self.v2_instance(table_name:)
        @@v2_instances ||= {}
        return @@v2_instances[table_name.to_sym] if @@v2_instances[table_name.to_sym]
        @@v2_instances[table_name.to_sym] = Hashids.new(ENV['HASH_ID_SALT_2'] + table_name.to_s, 22)
    end

    def self.decode(x, table_name:)
        first_val = x
        first_val = x.first if x.is_a?(Array)
        h_inst = first_val.to_s.length == 22 ? self.v2_instance(table_name: table_name) : self.v1_instance
        x.is_a?(Array) ? x.map { |i| h_inst.decode(i) } : h_inst.decode(x)&.first
    end

    def self.v1_hashid_decode(val)
        return false if val.blank? || val.to_s.length == 22 || !val.to_s.match?(/\A[A-Za-z0-9]{4,}\Z/)
        self.v1_instance.decode(val.to_s)&.first
    end
end