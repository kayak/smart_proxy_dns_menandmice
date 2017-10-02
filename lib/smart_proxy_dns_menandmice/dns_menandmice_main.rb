require 'dns_common/dns_common'
require 'mm_json_client'

module Proxy::Dns::Menandmice
  class Record < ::Proxy::Dns::Record
    include Proxy::Log

    attr_reader :client, :dns_ttl

    def initialize(client, dns_ttl = nil)
      @client = client
      super('localhost', dns_ttl)
    end

    def do_create(name, value, type)
      zone = match_zone(name, enum_zones)

      args = generate_args(name, type, value, zone)
      record = create_dns_record(args)
      response = @client.add_dns_record(dns_record: record)
      raise Proxy::Dns::Error.new("Failed to point #{name} to #{value} with type #{type}") unless response.ref
      response
    end

    def do_remove(name, type)
      zone = match_zone(name, enum_zones)
      record_filter = generate_filter_args(name, type, zone)
      response = @client.get_dns_records(record_filter)
      if response.total_results == 0
        raise Proxy::Dns::NotFound.new("Failed to remove #{name} of type #{type}")
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

    def create_dns_record(*args)
      MmJsonClient::DNSRecord.new(*args)
    end

    def generate_args(name, type, value, zone)
      {
          :name => "#{name}.",
          :type => type,
          :ttl => @ttl,
          :data => value,
          :enabled => true,
          :dns_zone_ref => zone.ref
      }
    end

    def generate_filter_args(name, type, zone)
      {
          :filter => "name:^#{name.split(zone.name).first.chop}$ type:#{type}",
          :dns_zone_ref => zone.ref
      }
    end
  end
end
