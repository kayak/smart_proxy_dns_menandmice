require 'smart_proxy_dns_menandmice/dns_menandmice_version'

module Proxy::Dns::Menandmice
  class Plugin < ::Proxy::Provider
    plugin :dns_menandmice, ::Proxy::Dns::Menandmice::VERSION

    # Settings listed under default_settings are required.
    # An exception will be raised if they are initialized with nil values.
    # Settings not listed under default_settings are considered optional and by default have nil value.
    default_settings :server => "127.0.0.1", :username => "username", :password => "password"

    requires :dns, '>= 1.15'

    # Loads plugin files and dependencies
    load_classes ::Proxy::Dns::Menandmice::PluginConfiguration
    # Loads plugin dependency injection wirings
    load_dependency_injection_wirings ::Proxy::Dns::Menandmice::PluginConfiguration
  end
end
