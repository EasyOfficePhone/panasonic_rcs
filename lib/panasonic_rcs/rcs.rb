module PanasonicRcs
  class Rcs
    attr_reader :connection, :response
    def initialize(connection)
      @connection = connection
    end

    def list_phones
      request = "<?xml version=\"1.0\"?><methodCall><methodName>ipredirect.listPhones</methodName></methodCall>"
      @response = connection.post(request)
      fail RcsError.new "System responded with a #{@response.status} status." if @response.status != 200

      body = @response.body['methodResponse']
      if fault = body['fault']
        fault_string = fault['value']['struct']['member'][1]['value']['string']
        fail RcsError.new fault_string
      end
      body['params']['param']['value']['array']['data']['value'].map {|k| k["string"]}
    end

    def phone(raw_mac_addr)
      mac_addr = raw_mac_addr.gsub(/[^[:alnum:]]/, '')
      body = "<?xml version=\"1.0\"?><methodCall><methodName>ipredirect.getPhone</methodName><params><param><value><string>#{mac_addr}</string></value></param></params></methodCall>"
      @response = connection.post(body)
      fail RcsError.new "System responded with a #{@response.status} status." if @response.status != 200

      body = @response.body['methodResponse']
      if fault = body['fault']
        fault_string = fault['value']['struct']['member'][1]['value']['string']
        fail RcsError.new fault_string
      end
      parse_struct(body['params']['param']['value']['struct']['member'])
    end

    def register_phone_with_profile(raw_mac_addr, profile)
      mac_addr = raw_mac_addr.gsub(/[^[:alnum:]]/, '')
      body = "<?xml version=\"1.0\"?><methodCall><methodName>ipredirect.registerPhoneWithProfile</methodName><params><param><value><string>#{mac_addr}</string></value></param><param><value><string>#{profile}</string></value></param></params></methodCall>"
      @response = connection.post(body)
      fail RcsError.new "System responded with a #{@response.status} status." if @response.status != 200

      body = @response.body['methodResponse']
      if fault = body['fault']
        fault_string = fault['value']['struct']['member'][1]['value']['string']
        fail RcsError.new fault_string
      end
      body['params']['param']['value']['boolean'] == "1"
    end

    def unregister_phone(raw_mac_addr)
      mac_addr = raw_mac_addr.gsub(/[^[:alnum:]]/, '')
      body = "<?xml version=\"1.0\"?><methodCall><methodName>ipredirect.unregisterPhone</methodName><params><param><value><string>#{mac_addr}</string></value></param></params></methodCall>"
      @response = connection.post(body)
      fail RcsError.new "System responded with a #{@response.status} status." if @response.status != 200

      body = @response.body['methodResponse']
      if fault = body['fault']
        fault_string = fault['value']['struct']['member'][1]['value']['string']
        fail RcsError.new fault_string
      end
      body['params']['param']['value']['boolean'] == "1"
    end

    private

    def parse_struct(struct)
      struct.each_with_object({}) {|member, obj| obj[member['name']] = parse_value(member['value'].keys.first, member['value'].values.first)}
    end

    def parse_value(value_type, value)
      type_conversion = {'string' => ->(x){x}, 'dateTime.iso8601' => ->(x) {DateTime.iso8601(x)}}
      translator = type_conversion.fetch(value_type) { ->(x) {x} }
      translator.call(value)
    end
  end
end
