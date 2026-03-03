# frozen_string_literal: true

require 'monitor'

module Faraknight
  # Adds the ability for other modules to register and lookup
  # middleware classes.
  module MiddlewareRegistry
    def registered_middleware
      @registered_middleware ||= {}
    end

    # Register middleware class(es) on the current module.
    #
    # @param mappings [Hash] Middleware mappings from a lookup symbol to a middleware class.
    # @return [void]
    #
    # @example Lookup by a constant
    #
    #   module Faraknight
    #     class Whatever < Middleware
    #       # Middleware looked up by :foo returns Faraknight::Whatever::Foo.
    #       register_middleware(foo: Whatever)
    #     end
    #   end
    def register_middleware(**mappings)
      middleware_mutex do
        registered_middleware.update(mappings)
      end
    end

    # Unregister a previously registered middleware class.
    #
    # @param key [Symbol] key for the registered middleware.
    def unregister_middleware(key)
      registered_middleware.delete(key)
    end

    # Lookup middleware class with a registered Symbol shortcut.
    #
    # @param key [Symbol] key for the registered middleware.
    # @return [Class] a middleware Class.
    # @raise [Faraknight::Error] if given key is not registered
    #
    # @example
    #
    #   module Faraknight
    #     class Whatever < Middleware
    #       register_middleware(foo: Whatever)
    #     end
    #   end
    #
    #   Faraknight::Middleware.lookup_middleware(:foo)
    #   # => Faraknight::Whatever
    def lookup_middleware(key)
      load_middleware(key) ||
        raise(Faraknight::Error, "#{key.inspect} is not registered on #{self}")
    end

    private

    def middleware_mutex(&block)
      @middleware_mutex ||= Monitor.new
      @middleware_mutex.synchronize(&block)
    end

    def load_middleware(key)
      value = registered_middleware[key]
      case value
      when Module
        value
      when Symbol, String
        middleware_mutex do
          @registered_middleware[key] = const_get(value)
        end
      when Proc
        middleware_mutex do
          @registered_middleware[key] = value.call
        end
      end
    end
  end
end
