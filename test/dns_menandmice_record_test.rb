require 'test_helper'
require 'smart_proxy_dns_menandmice/dns_menandmice_main'

class DnsMenandmiceRecordTest < Test::Unit::TestCase
  def setup
    @client = mock('MmJsonClient::Client')
    @provider = ::Proxy::Dns::Menandmice::Record.new(@client, 999)

    @provider.stubs(:enum_zones).returns(["example.com"])
    @provider.stubs(:match_zone).returns(stub('MmJsonClient::DNSZone', :ref => '123'))

    mockrecord = stub('MmJsonClient::DNSRecord', :ref => '456', :type => "DNSRecord")

    @client.stubs(:get_dns_records).returns(stub(:total_results => 1, :dns_records => [mockrecord]))

    @client.stubs(:add_dns_record).returns(mockrecord)
    @client.stubs(:remove_object).returns("")
  end

  # Test A record creation
  def test_create_a
    assert @provider.do_create('test.example.com', '10.1.1.1', 'A')
  end

  # Test AAAA record creation
  def test_create_aaaa
    assert @provider.do_create('test.example.com', '2001:db8::1', 'AAAA')
  end

  # Test PTR record creation with an IPv4 address
  def test_create_ptr_v4
    assert @provider.do_create('3.2.1.10.in-addr.arpa', 'test.example.com', 'PTR')
  end

  # Test PTR record creation with an IPv6 address
  def test_create_ptr_v6
    assert @provider.do_create('1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa', 'test.example.com', 'PTR')
  end

  # Test CNAME record creation
  def test_create_cname
    assert @provider.do_create('test.example.com', 'target.example.com', 'CNAME')
  end

  # Test A record removal
  def test_remove_a
    assert @provider.do_remove('test.example.com', 'A')
  end

  # Test AAAA record removal
  def test_remove_aaaa
    assert @provider.do_remove('test.example.com', 'AAAA')
  end

  # Test PTR record removal with an IPv4 address
  def test_remove_ptr_v4
    assert @provider.do_remove('3.2.1.10.in-addr.arpa', 'PTR')
  end

  # Test PTR record removal with an IPv6 address
  def test_remove_ptr_v6
    assert @provider.do_remove('1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa', 'PTR')
  end

  # Test CNAME record removal
  def test_remove_cname
    assert @provider.do_remove('test.example.com', 'CNAME')
  end
end
