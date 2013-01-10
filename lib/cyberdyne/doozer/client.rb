# require 'cyberdyne/doozer/msg.pb'
# require 'cyberdyne/doozer/exceptions'
require 'semantic_logger'
require 'resilient_socket'

SemanticLogger::Logger.appenders << SemanticLogger::Appender::File.new(STDOUT, :trace)

module Cyberdyne
  module Doozer
    class Client

      attr_accessor :logger, :config, :socket
      def initialize(params={})
        @logger, @config = SemanticLogger::Logger.new(self.class), {}
        setup_config params
        connect = Proc.new do |socket|
          socket.user_data = 0
        end
        @socket = ResilientSocket::TCPClient.new(config.merge(on_connect: connect))
      end

      def close
        socket.close if socket
      end

      private
      def setup_config params
        config[:read_timeout]            = params[:read_timeout]           || 5
        config[:connect_timeout]         = params[:connect_timeout]        || 3
        config[:connect_retry_interval]  = params[:connect_retry_interval] || 0.1
        config[:connect_retry_count]     = params[:connect_retry_count]    || 3
        config[:server]                  = (params[:server] || "127.0.0.1:8046") unless params[:servers]
        config[:buffered]                = false
      end

    end
  end
end
