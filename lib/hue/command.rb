module Hue
  class Command
    attr_reader :client, :bridge
    attr_accessor :action, :method, :body

    def initialize(client, bridge)
      @client = client
      @bridge = bridge
    end
    
    def to_param
      {
        address: "/api/#{@client.username}#{action}",
        method: method,
        body: body
      }
    end
  end
end
