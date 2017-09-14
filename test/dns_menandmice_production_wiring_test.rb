require 'test_helper'
require 'smart_proxy_dns_menandmice/dns_menandmice_configuration'
require 'smart_proxy_dns_menandmice/dns_menandmice_main'

class DnsMenandmiceProductionWiringTest < Test::Unit::TestCase
  def setup
    @container = ::Proxy::DependencyInjection::Container.new
    @config = ::Proxy::Dns::Menandmice::PluginConfiguration.new
  end

  def test_dns_provider_initialization
    @config.load_dependency_injection_wirings(@container, :dns_ttl => 999,
                                              :example_setting => 'a_value',
                                              :required_setting => 'required_value',
                                              :optional_path => '/some/path',
                                              :required_path => '/required/path')

    provider = @container.get_dependency(:dns_provider)

    assert_not_nil provider
    assert_equal 'a_value', provider.example_setting
    assert_equal 'required_value', provider.required_setting
    assert_equal '/some/path', provider.optional_path
    assert_equal '/required/path', provider.required_path
    assert_equal 999, provider.ttl
  end
end
