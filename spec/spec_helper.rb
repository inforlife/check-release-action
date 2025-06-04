$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), ".."))

require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data("<GITHUB_ACCESS_TOKEN>") { ENV["GITHUB_ACCESS_TOKEN"] }
end
