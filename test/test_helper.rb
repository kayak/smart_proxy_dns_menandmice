require 'test/unit'
require 'mocha/setup'
require 'json'
require 'ostruct'
require 'webmock/test_unit'

require 'smart_proxy_for_testing'

# create log directory in our (not smart-proxy) directory
FileUtils.mkdir_p File.dirname(Proxy::SETTINGS.log_file)

def mm_response(result, error, id)
    JSON.dump({
        :version => 0.1,
        :result => result,
        :error => error,
        :id => id
    })
end