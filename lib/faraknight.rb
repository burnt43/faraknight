# frozen_string_literal: true

require 'cgi/escape'
require 'cgi/util' if RUBY_VERSION < '3.5'
require 'date'
require 'set'
require 'forwardable'
require 'faraknight/version'
require 'faraknight/methods'
require 'faraknight/error'
require 'faraknight/middleware_registry'
require 'faraknight/utils'
require 'faraknight/options'
require 'faraknight/connection'
require 'faraknight/rack_builder'
require 'faraknight/parameters'
require 'faraknight/middleware'
require 'faraknight/adapter'
require 'faraknight/request'
require 'faraknight/response'
require 'faraknight/net_http'
# This is the main namespace for Faraknight.
#
# It provides methods to create {Connection} objects, and HTTP-related
# methods to use directly.
#
# @example Helpful class methods for easy usage
#   Faraknight.get "http://faraday.com"
#
# @example Helpful class method `.new` to create {Connection} objects.
#   conn = Faraknight.new "http://faraday.com"
#   conn.get '/'
#
module Faraknight
  CONTENT_TYPE = 'Content-Type'

  class << self
    # The root path that Faraknight is being loaded from.
    #
    # This is the root from where the libraries are auto-loaded.
    #
    # @return [String]
    attr_accessor :root_path

    # Gets or sets the path that the Faraknight libs are loaded from.
    # @return [String]
    attr_accessor :lib_path

    # @overload default_adapter
    #   Gets the Symbol key identifying a default Adapter to use
    #   for the default {Faraknight::Connection}. Defaults to `:net_http`.
    #   @return [Symbol] the default adapter
    # @overload default_adapter=(adapter)
    #   Updates default adapter while resetting {.default_connection}.
    #   @return [Symbol] the new default_adapter.
    attr_reader :default_adapter

    # Option for the default_adapter
    #   @return [Hash] default_adapter options
    attr_accessor :default_adapter_options

    # Documented below, see default_connection
    attr_writer :default_connection

    # Tells Faraknight to ignore the environment proxy (http_proxy).
    # Defaults to `false`.
    # @return [Boolean]
    attr_accessor :ignore_env_proxy

    # Initializes a new {Connection}.
    #
    # @param url [String,Hash] The optional String base URL to use as a prefix
    #           for all requests.  Can also be the options Hash. Any of these
    #           values will be set on every request made, unless overridden
    #           for a specific request.
    # @param options [Hash]
    # @option options [String] :url Base URL
    # @option options [Hash] :params Hash of unencoded URI query params.
    # @option options [Hash] :headers Hash of unencoded HTTP headers.
    # @option options [Hash] :request Hash of request options.
    # @option options [Hash] :ssl Hash of SSL options.
    # @option options [Hash] :proxy Hash of Proxy options.
    # @return [Faraknight::Connection]
    #
    # @example With an URL argument
    #   Faraknight.new 'http://faraday.com'
    #   # => Faraknight::Connection to http://faraday.com
    #
    # @example With an URL argument and an options hash
    #   Faraknight.new 'http://faraday.com', params: { page: 1 }
    #   # => Faraknight::Connection to http://faraday.com?page=1
    #
    # @example With everything in an options hash
    #   Faraknight.new url: 'http://faraday.com',
    #               params: { page: 1 }
    #   # => Faraknight::Connection to http://faraday.com?page=1
    def new(url = nil, options = {}, &block)
      options = Utils.deep_merge(default_connection_options, options)
      Faraknight::Connection.new(url, options, &block)
    end

    # Documented elsewhere, see default_adapter reader
    def default_adapter=(adapter)
      @default_connection = nil
      @default_adapter = adapter
    end

    def respond_to_missing?(symbol, include_private = false)
      default_connection.respond_to?(symbol, include_private) || super
    end

    # @overload default_connection
    #   Gets the default connection used for simple scripts.
    #   @return [Faraknight::Connection] a connection configured with
    #   the default_adapter.
    # @overload default_connection=(connection)
    #   @param connection [Faraknight::Connection]
    #   Sets the default {Faraknight::Connection} for simple scripts that
    #   access the Faraknight constant directly, such as
    #   <code>Faraknight.get "https://faraday.com"</code>.
    def default_connection
      @default_connection ||= Connection.new(default_connection_options)
    end

    # Gets the default connection options used when calling {Faraknight#new}.
    #
    # @return [Faraknight::ConnectionOptions]
    def default_connection_options
      @default_connection_options ||= ConnectionOptions.new
    end

    # Sets the default options used when calling {Faraknight#new}.
    #
    # @param options [Hash, Faraknight::ConnectionOptions]
    def default_connection_options=(options)
      @default_connection = nil
      @default_connection_options = ConnectionOptions.from(options)
    end

    private

    # Internal: Proxies method calls on the Faraknight constant to
    # .default_connection.
    def method_missing(name, *args, &block)
      if default_connection.respond_to?(name)
        default_connection.send(name, *args, &block)
      else
        super
      end
    end
  end

  self.ignore_env_proxy = false
  self.root_path = File.expand_path __dir__
  self.lib_path = File.expand_path 'faraday', __dir__
  self.default_adapter = :net_http
  self.default_adapter_options = {}
end
