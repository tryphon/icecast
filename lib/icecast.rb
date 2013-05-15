require "icecast/version"

require "null_logger"
require "parallel"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/class/attribute_accessors"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/enumerable"

module Icecast
  @@logger = NullLogger.instance
  mattr_accessor :logger
end

require 'icecast/null_cache'
require 'icecast/server'
require 'icecast/cluster'
