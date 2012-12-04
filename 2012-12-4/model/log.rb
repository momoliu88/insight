require 'logger'
class Log
  attr_accessor :logger
  @@log = nil
  def self.log
    (@@log = Logger.new ("./server.log"); @@log.level = Logger::DEBUG)unless @@log
    @@log
  end
end
