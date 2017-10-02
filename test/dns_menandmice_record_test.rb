require 'test_helper'
require 'smart_proxy_dns_menandmice/dns_menandmice_main'

class DnsMenandmiceRecordTest < Test::Unit::TestCase
  def setup
    @client = mock('MmJsonClient::Client')
    @ttl = 999
    @provider = ::Proxy::Dns::Menandmice::Record.new(@client, @ttl)

    @forward_zone = stub('a_zone', :ref => '567', :type => 'Master', :name => 'example.com')
    @reverse_zone_4 = stub('a_ipv4_rev_zone', :ref => '123', :type => 'Master', :name => 'in-addr.arpa')
    @reverse_zone_6 = stub('a_ipv6_rev_zone', :ref => '456', :type => 'Master', :name => 'ip6.arpa')
    @zones = stub('a_zonelist', :dns_zones => [@forward_zone, @reverse_zone_4, @reverse_zone_6])

    @client.stubs(:get_dns_zones).returns(@zones) # Used in all tests, returns the same thing always
    @response = stub('a_response', :ref => '24133') # No sense redelcaring all the time in each test
  end

  # Test A record creation
  def test_create_a
    expected_name = 'test.example.com'
    expected_address = '10.1.1.1'
    expected_type = 'A'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @forward_zone)
    record = MmJsonClient::DNSRecord.new(args)

    @client.stubs(:get_dns_zones).returns(@zones)
    @client.stubs(:match_zone).returns(@foward_zone)
    @provider.expects(:create_dns_record).with(has_entries(args)).returns(record)
    @client.expects(:add_dns_record).with(has_entry(:dns_record, record)).returns(@response)

    assert_equal @response,@provider.do_create(expected_name, expected_address, expected_type)
  end

  # Test AAAA record creation
  def test_create_aaaa
    expected_name = 'test.example.com'
    expected_address = '2001:db8::1'
    expected_type = 'AAAA'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @forward_zone)
    record = MmJsonClient::DNSRecord.new(args)

    @client.stubs(:match_zone).returns(@foward_zone)
    @provider.expects(:create_dns_record).with(has_entries(args)).returns(record)
    @client.expects(:add_dns_record).with(has_entry(:dns_record, record)).returns(@response)

    assert_equal @response, @provider.do_create(expected_name, expected_address, expected_type)
  end

  # Test PTR record creation with an IPv4 address
  def test_create_ptr_v4
    expected_name = '3.2.1.10.in-addr.arpa'
    expected_address = 'test.example.com'
    expected_type = 'PTR'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @reverse_zone_4)
    record = MmJsonClient::DNSRecord.new(args)

    @client.stubs(:match_zone).returns(@reverse_zone_4)
    @provider.expects(:create_dns_record).with(has_entries(args)).returns(record)
    @client.expects(:add_dns_record).with(has_entry(:dns_record, record)).returns(@response)

    assert_equal @response, @provider.do_create(expected_name, expected_address, expected_type)
  end

  # Test PTR record creation with an IPv6 address
  def test_create_ptr_v6
    expected_name = '1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa'
    expected_address = 'test.example.com'
    expected_type = 'PTR'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @reverse_zone_6)
    record = MmJsonClient::DNSRecord.new(args)

    @client.stubs(:match_zone).returns(@reverse_zone_6)
    @provider.expects(:create_dns_record).with(has_entries(args)).returns(record)
    @client.expects(:add_dns_record).with(has_entry(:dns_record, record)).returns(@response)

    assert_equal @response,@provider.do_create(expected_name, expected_address, expected_type)
  end

  # Test CNAME record creation
  def test_create_cname
    expected_name = 'test.example.com'
    expected_address = 'target.example.com'
    expected_type = 'CNAME'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @forward_zone)
    record = MmJsonClient::DNSRecord.new(args)

    @client.stubs(:get_dns_zones).returns(@zones)
    @client.stubs(:match_zone).returns(@foward_zone)
    @provider.expects(:create_dns_record).with(has_entries(args)).returns(record)
    @client.expects(:add_dns_record).with(has_entry(:dns_record, record)).returns(@response)

    assert_equal @response,@provider.do_create(expected_name, expected_address, expected_type)
  end

  # Test A record removal
  def test_remove_a
    expected_name = 'test.example.com'
    expected_address = '10.1.1.1'
    expected_type = 'A'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @forward_zone)
    record = MmJsonClient::DNSRecord.new(args)

    all_records = stub('a_response', :dns_records => [record], :total_results => 1)

    filter = @provider.generate_filter_args(expected_name, expected_type, @forward_zone)

    @client.stubs(:get_dns_zones).returns(@zones)
    @client.stubs(:match_zone).returns(@foward_zone)
    @client.expects(:get_dns_records).with(has_entries(filter)).returns(all_records)
    @client.expects(:remove_object).with(has_entries(:ref => record.ref, :obj_type => 'DNSRecord')).returns({})

    assert_equal Hash.new, @provider.do_remove(expected_name, expected_type)
  end

  # Test AAAA record removal
  def test_remove_aaaa
    expected_name = 'test.example.com'
    expected_address = '2001:db8::1'
    expected_type = 'AAAA'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @forward_zone)
    record = MmJsonClient::DNSRecord.new(args)

    all_records = stub('a_response', :dns_records => [record], :total_results => 1)

    filter = @provider.generate_filter_args(expected_name, expected_type, @forward_zone)

    @client.stubs(:get_dns_zones).returns(@zones)
    @client.stubs(:match_zone).returns(@foward_zone)
    @client.expects(:get_dns_records).with(has_entries(filter)).returns(all_records)
    @client.expects(:remove_object).with(has_entries(:ref => record.ref, :obj_type => 'DNSRecord')).returns({})

    assert_equal Hash.new, @provider.do_remove(expected_name, expected_type)
  end

  # Test PTR record removal with an IPv4 address
  def test_remove_ptr_v4
    expected_name = '3.2.1.10.in-addr.arpa'
    expected_address = 'test.example.com'
    expected_type = 'PTR'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @reverse_zone_4)
    record = MmJsonClient::DNSRecord.new(args)

    all_records = stub('a_response', :dns_records => [record], :total_results => 1)

    filter = @provider.generate_filter_args(expected_name, expected_type, @reverse_zone_4)

    @client.stubs(:get_dns_zones).returns(@zones)
    @client.stubs(:match_zone).returns(@reverse_zone_4)
    @client.expects(:get_dns_records).with(has_entries(filter)).returns(all_records)
    @client.expects(:remove_object).with(has_entries(:ref => record.ref, :obj_type => 'DNSRecord')).returns({})

    assert_equal Hash.new, @provider.do_remove(expected_name, expected_type)
  end

  # Test PTR record removal with an IPv6 address
  def test_remove_ptr_v6
    expected_name = '1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa'
    expected_address = 'test.example.com'
    expected_type = 'PTR'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @reverse_zone_6)
    record = MmJsonClient::DNSRecord.new(args)

    all_records = stub('a_response', :dns_records => [record], :total_results => 1)

    filter = @provider.generate_filter_args(expected_name, expected_type, @reverse_zone_6)

    @client.stubs(:get_dns_zones).returns(@zones)
    @client.stubs(:match_zone).returns(@reverse_zone_6)
    @client.expects(:get_dns_records).with(has_entries(filter)).returns(all_records)
    @client.expects(:remove_object).with(has_entries(:ref => record.ref, :obj_type => 'DNSRecord')).returns({})

    assert_equal Hash.new, @provider.do_remove(expected_name, expected_type)
  end

  # Test CNAME record removal
  def test_remove_cname
    expected_name = 'test.example.com'
    expected_address = 'target.example.com'
    expected_type = 'CNAME'
    args = @provider.generate_args(expected_name, expected_type, expected_address, @forward_zone)
    record = MmJsonClient::DNSRecord.new(args)

    all_records = stub('a_response', :dns_records => [record], :total_results => 1)

    filter = @provider.generate_filter_args(expected_name, expected_type, @forward_zone)

    @client.stubs(:get_dns_zones).returns(@zones)
    @client.stubs(:match_zone).returns(@foward_zone)
    @client.expects(:get_dns_records).with(has_entries(filter)).returns(all_records)
    @client.expects(:remove_object).with(has_entries(:ref => record.ref, :obj_type => 'DNSRecord')).returns({})

    assert_equal Hash.new, @provider.do_remove(expected_name, expected_type)
  end
end
