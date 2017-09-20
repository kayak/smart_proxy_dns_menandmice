require 'test_helper'
require 'smart_proxy_dns_menandmice/dns_menandmice_configuration'
require 'smart_proxy_dns_menandmice/dns_menandmice_main'

class DnsMenandmiceProductionWiringTest < Test::Unit::TestCase
  def setup
    @container = ::Proxy::DependencyInjection::Container.new
    @config = ::Proxy::Dns::Menandmice::PluginConfiguration.new

    stub_request(:post, "https://test.example.com/_mmwebext/mmwebext.dll?Soap").
        with(body: "{\"jsonrpc\":\"2.0\",\"method\":\"Login\",\"params\":{\"loginName\":\"example\\\\user\",\"password\":\"hunter12\",\"server\":\"test.example.com\"}}",
             headers: {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: mm_response({session: 123}, nil, 123), headers: {})
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
