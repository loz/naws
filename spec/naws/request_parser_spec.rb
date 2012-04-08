require 'spec_helper'

class MockSocket < StringIO

  def make_example_get
    self.string = <<-REQUEST
GET /a/get/url?arg1=value1&arg2=value2 HTTP/1.1\r
Host: www.example.com\r
X-A-Header: a header value\r
X-Another-Header: another header value\r
\r\n
    REQUEST
  end

  def make_example_post
    self.string = <<-REQUEST
POST /a/post/url HTTP/1.0\r
Host: www.example.com\r
\r\n
    REQUEST
  end
  def make_body
    self.string = <<-REQUEST
Line1
Line2
Line3
    REQUEST
  end
end

describe NAWS::RequestParser do

  describe :parse_request_line do
    before :each do
      @socket = MockSocket.new
      @socket.make_example_get
    end

    it "sets method" do
      subject.parse_request_line(@socket)
      subject.env["REQUEST_METHOD"].should == "GET"

      @socket.make_example_post
      subject.parse_request_line(@socket)
      subject.env["REQUEST_METHOD"].should == "POST"
    end

    it "sets http version" do
      subject.parse_request_line(@socket)
      subject.env["HTTP_VERSION"].should == "HTTP/1.1"

      @socket.make_example_post
      subject.parse_request_line(@socket)
      subject.env["HTTP_VERSION"].should == "HTTP/1.0"
    end

    it "set request path" do
      subject.parse_request_line(@socket)
      subject.env["REQUEST_PATH"].should == "/a/get/url"

      @socket.make_example_post
      subject.parse_request_line(@socket)
      subject.env["REQUEST_PATH"].should == "/a/post/url"

      subject.env["PATH_INFO"].should == subject.env["REQUEST_PATH"]
    end

    it "sets query string" do
      subject.parse_request_line(@socket)
      subject.env["QUERY_STRING"].should == "arg1=value1&arg2=value2"

      @socket.make_example_post
      subject.parse_request_line(@socket)
      subject.env["QUERY_STRING"].should be_nil
    end
  end

  describe :parse_headers do
    before :each do
      @socket = MockSocket.new
      @socket.make_example_get
      subject.parse_request_line(@socket)
    end

    it "sets headers under HTTP_xx" do
      subject.parse_headers(@socket)
      subject.env["HTTP_HOST"].should == "www.example.com"
      subject.env["HTTP_X_A_HEADER"].should == "a header value"
      subject.env["HTTP_X_ANOTHER_HEADER"].should == "another header value"
    end
  end

  describe :parse_body do
    before :each do
      @socket = MockSocket.new
      @socket.make_body
    end

    it "sets rack.input to an IO for body" do
      subject.parse_body(@socket)
      input = subject.env['rack.input']
      input.readline.should == "Line1\n"
      input.readline.should == "Line2\n"
      input.rewind
      input.readline.should == "Line1\n"
    end
  end


end
