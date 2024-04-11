require 'json'

class String
  def parse_to_json
    JSON.parse(self)
  rescue StandardError
    begin
      ActiveSupport::JSON.decode(self)
    rescue StandardError
      nil
    end
  end
end
