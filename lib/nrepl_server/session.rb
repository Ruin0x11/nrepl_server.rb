# lib/session.rb

class NReplServer::Session
  attr_accessor :stdin

  def initialize(client)
    @client = client
    @stdin = nil
  end
end
