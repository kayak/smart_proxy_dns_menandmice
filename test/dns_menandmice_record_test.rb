require 'test_helper'
require 'smart_proxy_dns_menandmice/dns_menandmice_main'

class DnsMenandmiceRecordTest < Test::Unit::TestCase
  def setup
    client = MmJsonClient::Client.new({:server => "test.example.com",
                                              :username => "example\\user",
                                              :password => "hunter12",
                                              :ssl => true,
                                              :verify_ssl => true
                                      })
    @provider = ::Proxy::Dns::Menandmice::Record.new(client, 999)
  end

  # Test A record creation
  def test_create_a
    @provider.expects(:do_create)
        .with('test.example.com', '10.1.1.1', 'A').returns(true)
    assert @provider.do_create('test.example.com', '10.1.1.1', 'A')
  end

  # Test AAAA record creation
  def test_create_aaaa
    @provider.expects(:do_create)
        .with('test.example.com', '2001:db8::1', 'AAAA').returns(true)
    assert @provider.do_create('test.example.com', '2001:db8::1', 'AAAA')
  end

  # Test PTR record creation with an IPv4 address
  def test_create_ptr_v4
    @provider.expects(:do_create)
        .with('3.2.1.10.in-addr.arpa', 'test.example.com', 'PTR').returns(true)
    assert @provider.do_create('3.2.1.10.in-addr.arpa', 'test.example.com', 'PTR')
  end

  # Test PTR record creation with an IPv6 address
  def test_create_ptr_v6
    @provider.expects(:do_create)
        .with('1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa', 'test.example.com', 'PTR')
        .returns(true)
    assert @provider.do_create('1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa', 'test.example.com', 'PTR')
  end

  # Test CNAME record creation
  def test_create_cname
    @provider.expects(:do_create)
        .with('test.example.com', 'target.example.com', 'CNAME').returns(true)
    assert @provider.do_create('test.example.com', 'target.example.com', 'CNAME')
  end

  # Test A record removal
  def test_remove_a
    @provider.expects(:do_remove)
        .with('test.example.com', 'A').returns(true)
    assert @provider.do_remove('test.example.com', 'A')
  end

  # Test AAAA record removal
  def test_remove_aaaa
    @provider.expects(:do_remove)
        .with('test.example.com', 'AAAA').returns(true)
    assert @provider.do_remove('test.example.com', 'AAAA')
  end

  # Test PTR record removal with an IPv4 address
  def test_remove_ptr_v4
    @provider.expects(:do_remove)
        .with('3.2.1.10.in-addr.arpa', 'PTR').returns(true)
    assert @provider.do_remove('3.2.1.10.in-addr.arpa', 'PTR')
  end

  # Test PTR record removal with an IPv6 address
  def test_remove_ptr_v6
    @provider.expects(:do_remove)
        .with('1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa', 'PTR')
        .returns(true)
    assert @provider.do_remove('1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa', 'PTR')
  end

  # Test CNAME record removal
  def test_remove_cname
    @provider.expects(:do_remove)
        .with('test.example.com', 'CNAME').returns(true)
    assert @provider.do_remove('test.example.com', 'CNAME')
  end
end
