require 'rack'
require 'socket'

class NAWS::Server
  def self.run(app, options)
    port = options[:Port] || 3000
    puts "Starting NAWS::Server, port #{port}"
    server = TCPServer.new port
    Thread.abort_on_exception = true
    loop do
      client = server.accept
      Thread.new do
        request = NAWS::RequestParser.new
        request.parse_request_line(client)
        request.parse_headers(client)
        request.parse_body(client)
        rack = app.call(request.env)
        response = NAWS::ResponseSender.new(rack)
        begin
          response.send_status(client)
          response.send_headers(client)
          response.send_body(client)
        rescue Errno::EPIPE
          warn "Pipe Closed: %s" % request.env["REQUEST_PATH"]
        end
        client.close
      end
    end
  end
end

Rack::Handler.register 'naws', NAWS::Server

