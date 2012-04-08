require "naws/version"

module NAWS
  autoload :RequestParser, 'naws/request_parser'
  autoload :ResponseSender, 'naws/response_sender'
  require 'naws/server'
end
