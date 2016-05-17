module Hue
  class Command

    ADDRESS_RANGE = 1..64
    METHODS = %w(POST PUT DELETE)
    BODY_RANGE = 1..90

    # Path to light resource, a group resource or any other bridge resource.
    # (not including "/api/<username>")
    attr_reader :action
    
    # The HTTP method used to send the body to the given address.
    # Either "POST", "PUT", "DELETE" for local addresses.
    attr_reader :method
    
    # JSON string to be sent to the relevant resource.
    attr_reader :body

    def initialize(client, bridge)
      @client = client
      @bridge = bridge
    end
    
    def action=(value)
      unless ADDRESS_RANGE.include? "/api/#{@client.username}#{value}".size
        raise InvalidValueParameter, "length of address must be between #{ADDRESS_RANGE.first} to #{ADDRESS_RANGE.last}"
      end
      @action = value
    end

    def method=(value)
      value.upcase!
      unless METHODS.include? value
        raise InvalidValueForParameter, 'method must be either "POST", "PUT", "DELETE"'
      end
      @method = value
    end

    def body=(value)
      unless BODY_RANGE.include? JSON.dump(value).size
        raise InvalidValueParameter, "length of body must be between #{BODY_RANGE.first} to #{BODY_RANGE.last}"
      end
      @body = value
    end

    def to_h
      {
        address: "/api/#{@client.username}#{action}",
        method: method,
        body: body
      }
    end
  end
end
