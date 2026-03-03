# frozen_string_literal: true

module FaradayMiddlewareSubclasses
  class SubclassNoOptions < Faraknight::Middleware
  end

  class SubclassOneOption < Faraknight::Middleware
    DEFAULT_OPTIONS = { some_other_option: false }.freeze
  end

  class SubclassTwoOptions < Faraknight::Middleware
    DEFAULT_OPTIONS = { some_option: true, some_other_option: false }.freeze
  end
end

Faraknight::Response.register_middleware(no_options: FaradayMiddlewareSubclasses::SubclassNoOptions)
Faraknight::Response.register_middleware(one_option: FaradayMiddlewareSubclasses::SubclassOneOption)
Faraknight::Response.register_middleware(two_options: FaradayMiddlewareSubclasses::SubclassTwoOptions)
