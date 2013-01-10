require 'moped/bson'

module Cyberdyne
  class Client

    attr_reader :service_name, :version, :region, :logger
    def initialize service_name, version="*", region="Development"
      @service_name = service_name
      @logger       = SemanticLogger::Logger.new("#{self.class.name}: #{service_name}/#{version}/#{region}")
      @version      = version
      @region       = region
    end



    def call method, params, connection_params={}
      # request_id = Moped::BSON::ObjectId.new.to_s
      # logger.tagged request_id do        
      #   logger.benchmark_info "Called Skynet Service: #{service_name}.#{method_name}" do
      #     retries = 0
      #     begin
      #       Connection.
      #     rescue

      #     end
      #   end
      # end
    end
  end
end