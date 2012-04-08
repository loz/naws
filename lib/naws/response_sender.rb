module NAWS
  class ResponseSender
    def initialize(rack_response)
      @status, @headers, @body = rack_response
    end

    def send_status(socket)
      socket.puts "HTTP/1.1 #{@status}\r"
    end

    def send_headers(socket)
      @headers['Server'] = "NotAWebServer 0.0.1"
      @headers.each { |h| socket.puts "%s: %s\r" % h }
      socket.puts "\r"
    end

    def send_body(socket)
      socket.print @body.join("\r\n")
    end
  end
end
