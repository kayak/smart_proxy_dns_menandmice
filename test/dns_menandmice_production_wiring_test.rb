require 'test_helper'
require 'smart_proxy_dns_menandmice/dns_menandmice_configuration'
require 'smart_proxy_dns_menandmice/dns_menandmice_main'

class DnsMenandmiceProductionWiringTest < Test::Unit::TestCase
  def setup
    @container = ::Proxy::DependencyInjection::Container.new
    @config = ::Proxy::Dns::Menandmice::PluginConfiguration.new

    MmJsonClient::Client.any_instance.stubs(:login => stubs(:session => 123))
  end

  def test_dns_provider_initialization
    @config.load_dependency_injection_wirings(@container,
                                              :server => "test.example.com",
                                              :username => "example\\user",
                                              :password => "hunter12",
                                              :dns_ttl => 999,
                                              :ssl => true,
                                              :verify_ssl => true,
                                            )

    provider = @container.get_dependency(:dns_provider)

    assert_not_nil provider
    options = provider.client.instance_variable_get(:@options)
    assert_equal 'test.example.com', options[:server]
    assert_equal 'example\\user', options[:username]
    assert_equal true, options[:ssl]
    assert_equal true, options[:verify_ssl]
    assert_equal 999, provider.ttl
  end
end
