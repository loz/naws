require 'rack'
require 'socket'

class NAWS::Server
  def self.run(app, options)
    p "Starting NAWS::Server, port 2000"
    server = TCPServer.new 2000
    loop do
      client = server.accept
      Thread.new do
        request = NAWS::RequestParser.new
        request.parse_request_line(client)
        request.parse_headers(client)
        request.parse_body(client)
        rack = app.call(request.env)
        response = NAWS::ResponseSender.new(rack)
        response.send_status(client)
        response.send_headers(client)
        response.send_body(client)
        client.close
      end
    end
  end
end

Rack::Handler.register 'naws', NAWS::Server

