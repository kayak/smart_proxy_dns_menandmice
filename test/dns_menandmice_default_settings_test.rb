require 'test_helper'
require 'smart_proxy_dns_menandmice/dns_menandmice_configuration'
require 'smart_proxy_dns_menandmice/dns_menandmice_plugin'

class DnsMenandmiceDefaultSettingsTest < Test::Unit::TestCase
  def test_default_settings
    Proxy::Dns::Menandmice::Plugin.load_test_settings({})
    assert_equal "127.0.0.1", Proxy::Dns::Menandmice::Plugin.settings.server
    assert_equal "username", Proxy::Dns::Menandmice::Plugin.settings.username
    assert_equal "password", Proxy::Dns::Menandmice::Plugin.settings.password
  end
end
