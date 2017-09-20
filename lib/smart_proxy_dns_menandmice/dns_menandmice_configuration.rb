require 'smart_proxy_dns_menandmice/mm_client_initializer'

module ::Proxy::Dns::Menandmice
  class PluginConfiguration
    def load_classes
      require 'dns_common/dns_common'
      require 'smart_proxy_dns_menandmice/dns_menandmice_main'
    end

    def load_dependency_injection_wirings(container_instance, settings)

      container_instance.singleton_dependency :mm_client, lambda { ::Proxy::Dns::Menandmice::MmClientInitializer.initialized_client(settings) }
      container_instance.dependency :dns_provider, (lambda do
        ::Proxy::Dns::Menandmice::Record.new(container_instance.get_dependency(:mm_client), settings[:dns_ttl])
      end)

    end
  end
end


