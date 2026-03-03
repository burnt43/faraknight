# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'faraknight/logging/formatter'

module Faraknight
  class Response
    # Logger is a middleware that logs internal events in the HTTP request
    # lifecycle to a given Logger object. By default, this logs to STDOUT. See
    # Faraknight::Logging::Formatter to see specifically what is logged.
    class Logger < Middleware
      DEFAULT_OPTIONS = { formatter: Logging::Formatter }.merge(Logging::Formatter::DEFAULT_OPTIONS).freeze

      def initialize(app, logger = nil, options = {})
        super(app, options)
        logger ||= ::Logger.new($stdout)
        formatter_class = @options.delete(:formatter)
        @formatter = formatter_class.new(logger: logger, options: @options)
        yield @formatter if block_given?
      end

      def call(env)
        @formatter.request(env)
        super
      end

      def on_complete(env)
        @formatter.response(env)
      end

      def on_error(exc)
        @formatter.exception(exc) if @formatter.respond_to?(:exception)
      end
    end
  end
end

Faraknight::Response.register_middleware(logger: Faraknight::Response::Logger)
