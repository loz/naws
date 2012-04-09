require 'spec_helper'

class MockSocket < StringIO
end

describe NAWS::ResponseSender do
  let(:ok_response) do
    [200, {"Content-Type"=>"text/html"}, ["hello world"]]
  end

  subject { described_class.new ok_response }

  describe :send_status do
    before :each do
      @socket = MockSocket.new
    end

    it "outputs the status code" do
      subject.send_status(@socket)
      @socket.string.should == "HTTP/1.1 200\r\n"

      @socket.string = ""
      another = described_class.new [404, {}, ""]
      another.send_status(@socket)
      @socket.string.should == "HTTP/1.1 404\r\n"
    end
  end

  describe :send_headers do
    before :each do
      @socket = MockSocket.new
    end

    it "adds a header for each on included" do
      subject.send_headers(@socket)
      @socket.string.should include "Content-Type: text/html\r\n"

      @socket.string = ""
      headers = {
        'Foo' => 'Bar',
        'Something-Else' => 'Another'
      }
      another = described_class.new [404, headers, ""]
      another.send_headers(@socket)
      @socket.string.should include "Foo: Bar\r\n"
      @socket.string.should include "Something-Else: Another\r\n"
    end

    it "adds a Server: header" do
      subject.send_headers(@socket)
      @socket.string.should include "Server: NotAWebServer 0.0.1\r\n"
    end

    it "adds a blank line at the end" do
      subject.send_headers(@socket)
      @socket.string.should match /(\r\n){2}\z/
    end
  end

  describe :send_body do
    before :each do
      @socket = MockSocket.new
    end

    it "adds each body" do
      subject.send_body(@socket)
      @socket.string.should == ok_response[2][0]

      bodies = [
        "Body1",
        "Body2",
        "Body3"
      ]
      @socket.string = ""
      another = described_class.new [404, {}, bodies]
      another.send_body(@socket)
      @socket.string.should == "Body1Body2Body3"
    end
  end
end
