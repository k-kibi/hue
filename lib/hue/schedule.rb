module Hue
  class Schedule
    include Enumerable
    include TranslateKeys
    include EditableState

    # ID of the schedule.
    attr_reader :id

    # Bridge the schedule is associeated with
    attr_reader :bridge

    # Name of the schedule.
    attr_accessor :name

    # Description of the schedule.
    attr_accessor :description

    attr_accessor :command

    def initialize(client, bridge, id = nil, data = {})
      @client = client
      @bridge = bridge
      @id = id
      unpack data
    end

    def create!(command, time, attributes = {})
      body = attributes
      body[:command] = command.to_param
      body[:localtime] = time

      uri = URI.parse "http://#{@bridge.ip}/api/#{@client.username}/schedules"
      http = Net::HTTP.new uri.host
      response = http.request_post uri.path, JSON.dump(body)
      json = JSON(response.body)

      @id = json[0]['success']['id']
    end

  private
    
    def base_url
      "http://#{bridge.ip}/api/#{@client.username}/schedules/#{id}"
    end
  end
end
