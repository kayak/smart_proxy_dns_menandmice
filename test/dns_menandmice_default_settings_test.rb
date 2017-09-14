require 'test_helper'
require 'smart_proxy_dns_menandmice/dns_menandmice_configuration'
require 'smart_proxy_dns_menandmice/dns_menandmice_plugin'

class DnsMenandmiceDefaultSettingsTest < Test::Unit::TestCase
  def test_default_settings
    Proxy::Dns::Menandmice::Plugin.load_test_settings({})
    assert_equal "default_value", Proxy::Dns::Menandmice::Plugin.settings.required_setting
    assert_equal "/must/exist", Proxy::Dns::Menandmice::Plugin.settings.required_path
  end
end
