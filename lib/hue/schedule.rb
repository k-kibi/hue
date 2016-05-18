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

    def initialize(client, bridge, id = nil, data = {})
      @client = client
      @bridge = bridge
      @id = id
      unpack_hash data, KEYS_MAP
    end

    def create!(command, time)
      body = {
        command: command.to_h,
        localtime: time.iso8601.split('+')[0]
      }
      uri = URI.parse "http://#{@bridge.ip}/api/#{@client.username}/schedules"
      http = Net::HTTP.new uri.host
      response = http.request_post uri.path, JSON.dump(body)
      json = JSON(response.body).first

      @id = json['success']['id']
    rescue
      raise ERROR_MAP[json['error']['type'].to_i]
    end

  private
    
    KEYS_MAP = {
      :name => :name,
      :description => :description,
      :command => :command,
      :time => :localtime,
      :status => :status,
      :auto_delete => :autodelete
    }

    def base_url
      "http://#{bridge.ip}/api/#{@client.username}/schedules/#{id}"
    end
  end
end
