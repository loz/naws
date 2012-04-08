require 'rack'
require 'naws'

Rack::Server.start(
  :app => lambda do |e|
    p e
    [200, {'Content-Type' => 'text/html'}, ['hello world']]
  end,
  :server => 'naws'
)
