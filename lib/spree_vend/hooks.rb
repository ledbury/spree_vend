class SpreeVend::Hooks

  class << self

    def parse_payload(json_payload)
      SpreeVend.parse_json_response json_payload
    end

  end

end
