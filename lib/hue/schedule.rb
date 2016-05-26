module Hue
  class Schedule
    include Enumerable
    include TranslateKeys

    # ID of the schedule.
    attr_reader :id

    # Bridge the schedule is associeated with
    attr_reader :bridge

    # Name of the schedule.
    attr_accessor :name

    # Description of the schedule.
    attr_accessor :description

    # Command to execute when the scheduled event occurs.
    attr_reader :command

    # Local time when the scheduled event will occur.
    attr_reader :localtime

    # Application is only allowed to set “enabled” or “disabled”.
    # Disabled causes a timer to reset when activated (i.e. stop & reset).
    # “enabled” when not provided on creation.
    attr_reader :status

    # If set to true, the schedule will be removed automatically if expired,
    # if set to false it will be disabled. Default is true. Only visible for
    # non-recurring schedules.
    attr_reader :auto_delete

    # When true: Resource is automatically deleted when not referenced anymore
    # in any resource link. Only on creation of resource.
    # “false” when omitted.
    attr_reader :recycle

    def initialize(client, bridge, id = nil, data = {})
      @client = client
      @bridge = bridge
      @id = id

      unpack(data)
    end

    def set_state(attributes)
      translate_keys(attributes, SCHEDULE_KEYS_MAP).each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      return if new?
      body = request_params
      uri = URI.parse(base_url)
      http = Net::HTTP.new(uri.host)
      response = http.request_put(uri.path, JSON.dump(body))
      JSON(response.body)
    end

    def refresh
      json = JSON(Net::HTTP.get(URI.parse(base_url)))
      unpack(json)
    end

    def create!
      body = request_params
      uri = URI.parse "http://#{@bridge.ip}/api/#{@client.username}/schedules"
      http = Net::HTTP.new uri.host
      response = http.request_post uri.path, JSON.dump(body)
      json = JSON(response.body).first

      @id = json['success']['id']
    rescue
      raise ERROR_MAP[json['error']['type'].to_i]
    end

    def destroy!
      uri = URI.parse(base_url)
      http = Net::HTTP.new(uri.host)
      response = http.delete(uri.path)
      json = JSON(response.body)
      @id = nil if json[0]['success']
    end

    def new?
      @id.nil?
    end
    
  private
    
    SCHEDULE_KEYS_MAP = {
      :name => :name,
      :description => :description,
      :command => :command,
      :time => :localtime,
      :created_at => :created,
      :status => :status,
      :auto_delete => :autodelete,
      :recycle => :recycle
    }

    def unpack(data)
      unpack_hash(data, SCHEDULE_KEYS_MAP)

      unless new?
        @command = Command.new(@client, @command)
      end
    end

    def base_url
      "http://#{@bridge.ip}/api/#{@client.username}/schedules/#{id}"
    end

    def request_params
      body = {command: @command, localtime: @localtime}
      body[:command] = @command.to_h if @command.is_a?(Command)
      body[:localtime] = @localtime.iso8601.split('+')[0] if @localtime.is_a?(Time)
      # optional parameters
      SCHEDULE_KEYS_MAP.reject { |key, value| [:command, :localtime].include? key }.each do |key, value|
        val = instance_variable_get("@#{key}")
        body[value] = val unless val.nil?
      end
      body
    end
  end
end
