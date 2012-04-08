module NAWS
  class RequestParser
    attr_reader :env

    def initialize
      @env = {}
    end

    def parse_request_line(socket)
      line = socket.readline
      method, resource, http = line.split(' ')
      path, query = resource.split('?')
      @env["REQUEST_METHOD"] = method
      @env["HTTP_VERSION"] = http
      @env["REQUEST_PATH"] = @env["PATH_INFO"] = path
      @env["QUERY_STRING"] = query
      @env["SCRIPT_NAME"] = ""
    end

    def parse_headers(socket)
      while line = socket.readline
        t = line.strip.match /(?<h>[\w-]+):\s*(?<v>.*)/
        if t
          header, value = t[:h], t[:v]
          @env["HTTP_#{header.upcase.gsub /\-/, '_'}"] = value
        end
        break if line == "\r\n"
      end
    end

    def parse_body(socket)
      body = StringIO.new
      #while line = socket.readline
      #  break if line == "\r\n"
      #  body << line
      #end
      #body.rewind
      @env['rack.input'] = body
    end
  end
end
