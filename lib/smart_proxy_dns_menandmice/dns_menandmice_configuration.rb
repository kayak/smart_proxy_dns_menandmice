module ::Proxy::Dns::Menandmice
  class PluginConfiguration
    def load_classes
      require 'dns_common/dns_common'
      require 'smart_proxy_dns_menandmice/dns_menandmice_main'
    end

    def load_dependency_injection_wirings(container_instance, settings)
      container_instance.dependency :dns_provider, (lambda do
        ::Proxy::Dns::Menandmice::Record.new(
            settings[:required_setting],
            settings[:example_setting],
            settings[:required_path],
            settings[:optional_path],
            settings[:dns_ttl])
      end)
    end
  end
end
