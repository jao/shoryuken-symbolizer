require 'shoryuken'
require 'active_support/core_ext/hash'
require "shoryuken/symbolizer/version"

module Shoryuken
  module Symbolizer
    def self.register
      Shoryuken.configure_server do |config|
        config.server_middleware do |chain|
          Shoryuken.logger.debug "shoryuken.symbolizer.hook added"
          chain.add Shoryuken::Symbolizer::Hook
        end
      end
    end

    class Hook
      def call(worker, queue, sqs_msg, body)
        body.deep_symbolize_keys!
        yield
      end
    end
  end
end

Shoryuken::Symbolizer.register
