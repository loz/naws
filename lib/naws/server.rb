require 'rack'
require 'socket'

class NAWS::Server
  def self.run(app, options)
    p "Starting NAWS::Server, port 2000"
    server = TCPServer.new 2000
    loop do
      client = server.accept
      request = NAWS::RequestParser.new
      request.parse_request_line(client)
      request.parse_headers(client)
      response = NAWS::ResponseSender.new(app.call(request.env))
      response.send_status(client)
      response.send_headers(client)
      response.send_body(client)
      client.close
    end
  end
end

Rack::Handler.register 'naws', NAWS::Server

