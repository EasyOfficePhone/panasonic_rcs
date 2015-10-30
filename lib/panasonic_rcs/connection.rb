require 'faraday'
require 'faraday_middleware'
require 'multi_xml'
module PanasonicRcs
  class Connection
    attr_reader :host
    attr_accessor :log

    def initialize(username: '', password: '', log: nil, adapter: [:net_http])
      @conn = Faraday.new(url: "https://provisioning.e-connecting.net/") do |builder|
        builder.use Faraday::Request::BasicAuthentication, username, password
        builder.use FaradayMiddleware::ParseXml, content_type: /\bxml$/
        builder.use Faraday::Response::Logger, log if log
        builder.adapter *adapter
      end
    end

    def post(body)
      @conn.post do |req|
        req.url '/redirect/xmlrpc'
        req.headers['Content-Type'] = 'text/xml'
        req.body = body
      end
    end
  end
end
