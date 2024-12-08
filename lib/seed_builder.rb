require "seed_builder/config"
require "seed_builder/loader"

module SeedBuilder
  VERSION = "1.0.1".freeze

  module_function

  def config
    @@config ||= Config.new
  end

  def configure
    yield config
  end
end
