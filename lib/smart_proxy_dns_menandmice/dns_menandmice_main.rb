require 'dns_common/dns_common'
require 'mm_json_client'

module Proxy::Dns::Menandmice
  class Record < ::Proxy::Dns::Record
    include Proxy::Log

    attr_reader :server, :username, :password, :ssl, :verify_ssl

    def initialize(server, username, password, dns_ttl = nil, ssl = false, verify_ssl = false, mock_login = false)
      @server = server
      @username = username
      @password = password
      @ssl =  ssl
      @verify_ssl = verify_ssl

      @client = MmJsonClient::Client.new(server: @server,
                                         username: @username,
                                         password: @password,
                                         ssl: @ssl,
                                         verify_ssl: @verify_ssl
                                        )

      @client.login unless mock_login

      super(server, dns_ttl)
    end

    def do_create(name, value, type)
      zone = match_zone(name, enum_zones)
      record = MmJsonClient::DNSRecord.new(name: "#{name}.", type: type, ttl: @dns_ttl,
                                           data: value, enabled: true,
                                           dns_zone_ref: zone.ref)
      response = @client.add_dns_record(dns_record: record)
      raise Proxy::Dns::Error.new("Failed to point #{name} to #{value} with type #{type}") unless response
      response
    end

    def do_remove(name, type)
      zone = match_zone(name, enum_zones)
      record_filter = "name:^#{name.split(".").first}$ type:#{type}"
      response = @client.get_dns_records(filter: record_filter, dns_zone_ref: zone.ref)
      if response.total_results == 0
        raise Proxy::Dns::Error.new("Failed to remove #{name} of type #{type}")
      end
      record = response.dns_records.first
      @client.remove_object(ref: record.ref, obj_type: 'DNSRecord')
    end

    def match_zone(record, zone_list)
      weight = 0 # sub zones might be independent from similar named parent zones; use weight for longest suffix match
      matched_zone = nil
      zone_list.each do |zone|
        zone_labels = zone.name.downcase.split(".").reverse
        zone_weight = zone_labels.length
        fqdn_labels = record.downcase.split(".")
        fqdn_labels.shift
        is_match = zone_labels.all? { |zone_label| zone_label == fqdn_labels.pop }
        # match only the longest zone suffix
        if is_match && zone_weight >= weight
          matched_zone = zone
          weight = zone_weight
        end
      end
      raise Proxy::Dns::NotFound.new("The DNS server has no authoritative zone for #{record}") unless matched_zone
      matched_zone
    end

    def enum_zones
      zones = []
      response = @client.get_dns_zones
      response.dns_zones.each do |zone|
        if zone.type == "Master"
          zones << zone
        end
      end
      zones
    end

  end
end