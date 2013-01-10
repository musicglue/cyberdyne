require 'semantic_logger'
require 'resilient_socket'
require 'cyberdyne/doozer/exceptions'
require 'cyberdyne/doozer/msg.pb'

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

      def current_revision
        invoke(Request.new(:verb => Request::Verb::REV)).rev
      end

      def get path, rev=nil
        invoke(
          Request.new(path: path, rev: rev, verb: Request::Verb::GET)
        )
      end

      def set path, value, rev=-1
        invoke(
          Request.new(path: path, value: value, rev: rev, verb: Request::Verb::SET), false
        ).rev
      end

      def delete path, rev=-1
        invoke(
          Request.new(path: path, rev: rev, verb: Request::Verb::DEL)
        )
        nil
      end

      def []= path, value
        set(path, value)
      end

      def [] path
        get(path).value
      end

      def stat path, rev=nil
        invoke(
          Request.new(path: path, rev: rev, verb: Request::Verb::STAT)
        )
      end

      def access secret
        invoke(
          Request.new(path: secret, verb: Request::Verb::ACCESS)
        )
      end

      def directory path, offset=0, rev=nil
        invoke(
          Request.new(path: path, rev: rev, offset: offset, verb: Request::Verb::GETDIR)
        )
      rescue ResponseError => e
        raise e unless e.message.include?('RANGE')
        nil
      end

      def walk path, rev=nil, offset=0
        paths = []
        revision = rev || current_revision
        socket.retry_on_connection_failure do
          while true
            send(
              Request.new(path: path, rev: revision, offset: offset, verb: Request::Verb::WALK)
            )
            response = read
            if response.err_code
              break if response.err_code == Response::Err::RANGE
            else
              raise ResponseError.new("#{Response::Err.name_by_value(response.err_code)}: #{response.err_detail}") if response.err_code != nil
            end
            paths << response.value
            offset += 1
          end
        end
        paths
      end

      def wait path, rev=current_revision, timeout=-1
        invoke(
          Request.new(path: path, rev: rev, verb: Request::Verb::WAIT), true, timeout
        )
      end

      def watch path, rev=current_revision
        loop do
          result = wait(path, rev, -1)
          yield result
          rev = result.rev + 1
        end
      end


      def doozer_hosts
        walk('/ctl/node/*/addr', current_revision).each_with_object([]) do |node, arr|
          arr << node unless arr.include?(node)
        end
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

      protected
      def invoke request, readonly=true, timeout=nil
        raise ArgumentError if !(request.is_a? Request)
        retry_read = readonly || !request.rev.nil?
        response = nil
        socket.retry_on_connection_failure do
          send(request)
          response = read(timeout) if retry_read
        end
        response = read(timeout) unless retry_read
        raise ResponseError.new("#{Response::Err.name_by_value(response.err_code)}: #{response.err_detail}") if response.err_code != 0
        response
      end

      def send request
        raise ArgumentError if !(request.is_a? Request)
        request.tag = 0
        data = request.serialize_to_string

        head = [data.length].pack("N")
        socket.write(head+data)
      end

      def read timeout=nil
        head = socket.read 4, nil, timeout
        length = head.unpack("N")[0]
        Response.new.parse_from_string(socket.read(length))
      end
    end
  end
end
