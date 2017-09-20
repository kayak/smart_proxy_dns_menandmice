require 'mm_json_client'

module ::Proxy::Dns::Menandmice
  class MmClientInitializer
    extend ::Proxy::Log
    def self.initialized_client(settings)
      client = MmJsonClient::Client.new(server: settings[:server],
                                        username: settings[:username],
                                        password: settings[:password],
                                        ssl: settings[:ssl],
                                        verify_ssl: settings[:verify_ssl])
      client.login
      client
    rescue MmJsonClient::ServerConnectionError, MmJsonClient::ServerError => e
      logger.fatal("Could not login to Men & Mice server", e)
      raise e
    end
  end
end
