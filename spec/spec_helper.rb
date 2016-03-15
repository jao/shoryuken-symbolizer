require 'simplecov'
require 'simplecov-rcov'

class SimpleCov::Formatter::MergedFormatter
  def format(result)
     SimpleCov::Formatter::HTMLFormatter.new.format(result)
     SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end
SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

SimpleCov.minimum_coverage 80
SimpleCov.maximum_coverage_drop 5

SimpleCov.start do
  add_filter '/config/'
  add_filter 'config'
  add_filter '/spec/'

  add_group 'Libraries', 'lib'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'shoryuken/symbolizer'

Shoryuken.logger.level = Logger::UNKNOWN

class TestWorker
  include Shoryuken::Worker
  shoryuken_options queue: 'default'
  def perform(sqs_msg, body); end
end

RSpec.configure do |config|

  config.before do
    Shoryuken::Client.class_variable_set :@@queues, {}
    Shoryuken::Client.class_variable_set :@@visibility_timeouts, {}

    Shoryuken::Client.sqs = nil
    Shoryuken::Client.sqs_resource = nil
    Shoryuken::Client.sns = nil

    Shoryuken.queues.clear

    Shoryuken.options[:concurrency] = 1
    Shoryuken.options[:delay]       = 1
    Shoryuken.options[:timeout]     = 1
    Shoryuken.options[:aws].delete(:receive_message)

    TestWorker.get_shoryuken_options.clear
    TestWorker.get_shoryuken_options['queue'] = 'default'

    Shoryuken.worker_registry.clear
    Shoryuken.register_worker('default', TestWorker)
  end
end