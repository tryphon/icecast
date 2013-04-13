require "icecast/version"

require "null_logger"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/class/attribute_accessors"
require "active_support/core_ext/object/blank"

module Icecast
  @@logger = NullLogger.instance
  mattr_accessor :logger
end

require 'icecast/server'

