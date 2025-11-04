require "active_support/tagged_logging"
require "seed_builder/config"
require "seed_builder/loader"

module SeedBuilder
  VERSION = "1.3.0".freeze

  module_function

  def config
    @@config ||= Config.new
  end

  def configure
    yield config
  end

  def logger
    # Use configured logger if set
    base_logger = if config.logger
      config.logger
    elsif defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
      Rails.logger
    else
      Logger.new($stdout)
    end

    # If the logger already supports tagging (e.g., Rails.logger is already TaggedLogging),
    # use it directly to avoid double-wrapping and ensure tags propagate properly
    if base_logger.respond_to?(:tagged)
      base_logger
    else
      ActiveSupport::TaggedLogging.new(base_logger)
    end
  end
end

require "rails_config"
require "seed_builder/railtie" if defined?(Rails::Railtie)
