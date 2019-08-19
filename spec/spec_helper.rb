require 'bundler/setup'
require 'ruby/plugin'
require 'ruby/plugin/worker'
require 'pry-byebug'
# HTTP Request recording
require 'vcr'
require 'webmock/rspec'
require_relative 'sneakers_helpers'

VCR.configure do |c|
  # this line is important so that only those specs with the "vcr" metadata are mocked instead
  # of actually hitting the API
  c.allow_http_connections_when_no_cassette = false
  c.ignore_hosts 'localhost', 'www.fakewebsite.dev'
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {
    match_requests_on: %i[method uri query body headers]
  }
  c.configure_rspec_metadata!
  c.debug_logger = STDOUT if ENV['DEBUG_VCR']
end

RSpec.configure do |config|
  config.include WorkerAdditions
  config.include Sneakers::Testing

  config.before(:each) do
    Sneakers::Testing.clear_all
  end

  config.around(:each, fake_publisher: true) do |example|
    Ruby::Plugin::Worker.include(WorkerAdditions)
    example.run
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
