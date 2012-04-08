require 'socket'

def parse_headers(sock)
  rawheader = ""
  while line = sock.gets # Read lines from socket
      break if line == "\r\n"
      rawheader << line
  end
  token = rawheader.split("\r\n").map do |h|
    t = h.match /(?<h>\w+):\s*(?<v>.*)/
    [t[:h], t[:v]]
  end
  Hash[token]
end

def parse_request(sock)
  raw = sock.gets
  Hash[[:method, :resource, :protocol].zip(raw.strip.split(' '))]
end

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  puts "Reading"
  request = parse_request(client)
  headers = parse_headers(client)
  p "REQ:", request
  puts '---'
  p headers
  puts "Sending"
  client.puts "HTTP/1.1 200 OK\r\n"
  client.puts "Content-Type: text/html\r\n\r\n"
  client.puts "Hello !"
  client.puts "Time is #{Time.now}"
  client.puts <<-HTML
<form method='post'>
<input type=text name=foo>
<input type=submit>
</form>
  HTML
  client.close
end

