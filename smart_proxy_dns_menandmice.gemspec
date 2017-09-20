require File.expand_path('../lib/smart_proxy_dns_menandmice/dns_menandmice_version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_dns_menandmice'
  s.version     = Proxy::Dns::Menandmice::VERSION
  s.date        = Date.today.to_s
  s.license     = 'GPL-3.0'
  s.authors     = ['Neil Hanlon']
  s.email       = ['nhanlon@kayak.com']
  s.homepage    = 'https://github.com/kayak/smart_proxy_dns_menandmice'

  s.summary     = "MenAndMice DNS provider plugin for Foreman's smart proxy"
  s.description = "MenAndMice DNS provider plugin for Foreman's smart proxy"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.add_dependency('mm_json_client')

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('test-unit')
end
