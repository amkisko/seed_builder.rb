require "spec_helper"

# Define Rails::Railtie stub for testing
unless defined?(Rails::Railtie)
  module Rails
    class Railtie
      def self.config
        @config ||= Class.new do
          def to_prepare(&block)
            @to_prepare_blocks ||= []
            if block_given?
              @to_prepare_blocks << block
            end
            self
          end

          def call_to_prepare
            (@to_prepare_blocks || []).each(&:call)
          end
        end.new
      end
    end
  end
end

# Load the Railtie manually since it's conditionally required
require_relative "../../lib/seed_builder/railtie"

class SeedBuilderUser < ActiveRecord::Base; end
class SeedUser < SeedBuilderUser; end

describe SeedBuilder::Railtie do
  let(:app_class) do
    Class.new do
      def initialize
        @prepared = false
      end

      def load_seed
        # Default implementation - should be patched by Railtie
        raise "Original load_seed called"
      end

      def prepare!
        @prepared = true
      end

      def prepared?
        @prepared
      end
    end
  end

  let(:rails_application) { app_class.new }
  let(:logger) { Logger.new($stdout) }
  let(:seeds_path) { File.expand_path("../../fixtures/seeds", __FILE__) }
  let(:default_seeds_path) { File.expand_path("../../fixtures/seeds.rb", __FILE__) }

  before do
    # Set up Rails.application mock
    # In Rails, Rails.application.class_eval works because Rails.application is an instance
    # and class_eval is called on it, which modifies the class.
    # We need to stub this properly.
    allow(Rails).to receive(:application).and_return(rails_application)
    allow(Rails).to receive(:root).and_return(rails_root)
    allow(Rails).to receive(:env).and_return(rails_env)
    allow(Rails).to receive(:logger).and_return(logger)
    allow(Rails).to receive(:logger=)

    SeedBuilder.configure do |config|
      config.seeds_full_path = seeds_path
      config.default_seeds_full_path = default_seeds_path
      config.load_default_seeds = true
      config.load_seeds = true
      config.use_seed_loader = true
    end

    # Clear any existing data
    SeedUser.delete_all
    SeedBuilderUser.delete_all
  end

  describe "Rails.application.load_seed integration" do
    context "when use_seed_loader is enabled" do
      before do
        # Simulate Rails initialization by running the Railtie's to_prepare blocks
        SeedBuilder::Railtie.config.call_to_prepare
      end

      it "patches Rails.application.load_seed to use SeedBuilder loader" do
        expect { rails_application.load_seed }.not_to raise_error
      end

      it "loads seeds using SeedBuilder loader" do
        rails_application.load_seed
        expect(SeedUser.count).to eq 1
        expect(SeedBuilderUser.count).to eq 1
      end
    end

    context "when use_seed_loader is disabled" do
      before do
        SeedBuilder.configure do |config|
          config.use_seed_loader = false
        end
        # Simulate Rails initialization by running the Railtie's to_prepare blocks
        SeedBuilder::Railtie.config.call_to_prepare
      end

      it "does not patch Rails.application.load_seed" do
        expect { rails_application.load_seed }.to raise_error("Original load_seed called")
      end
    end
  end
end
