require "seed_builder/config"
require "seed_builder/loader"

module SeedBuilder
  VERSION = "1.0.0".freeze

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end
end
