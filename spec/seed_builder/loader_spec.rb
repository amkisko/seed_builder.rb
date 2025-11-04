require "spec_helper"

# Define Rails module if not already defined
unless defined?(Rails)
  module Rails
    class << self
      attr_accessor :root, :env, :logger
    end
  end
end

class SeedBuilderUser < ActiveRecord::Base; end

class SeedUser < SeedBuilderUser; end

describe SeedBuilder::Loader do
  subject(:loader) { described_class.new }

  let(:logger) { Logger.new($stdout) }
  let(:seeds_path) { File.expand_path("../../fixtures/seeds", __FILE__) }
  let(:default_seeds_path) { File.expand_path("../../fixtures/seeds.rb", __FILE__) }

  before do
    allow(Rails).to receive(:root).and_return(rails_root)
    allow(Rails).to receive(:env).and_return(rails_env)
    allow(Rails).to receive(:logger).and_return(logger)
    allow(Rails).to receive(:logger=)
    # Reset SeedBuilder logger to pick up the stubbed Rails.logger
    SeedBuilder.instance_variable_set(:@logger, nil) if SeedBuilder.instance_variable_defined?(:@logger)

    SeedBuilder.configure do |config|
      config.seeds_full_path = seeds_path
      config.default_seeds_full_path = default_seeds_path
      config.load_default_seeds = true
      config.load_seeds = true
    end
  end

  describe "#load_seed" do
    before do
      SeedUser.delete_all
      SeedBuilderUser.delete_all
    end

    context "when loading default seeds" do
      let(:load_default_seeds) { true }
      let(:load_seeds) { true }

      before do
        SeedBuilder.configure do |config|
          config.load_default_seeds = load_default_seeds
          config.load_seeds = load_seeds
        end
        loader.load_seed
      end

      it "loads the seeds" do
        expect(SeedUser.count).to eq 1
        expect(SeedBuilderUser.count).to eq 1
      end
    end

    context "when seeds directory does not exist" do
      let(:log_output) { StringIO.new }
      let(:test_logger) { Logger.new(log_output) }

      before do
        allow(Rails).to receive(:logger).and_return(test_logger)
        # Reset SeedBuilder logger to pick up the stubbed Rails.logger
        SeedBuilder.instance_variable_set(:@logger, nil) if SeedBuilder.instance_variable_defined?(:@logger)
        SeedBuilder.configure do |config|
          config.seeds_full_path = "/non/existent/path"
          config.load_default_seeds = false
          config.load_seeds = true
        end
      end

      it "outputs a message" do
        loader.load_seed
        expect(log_output.string).to match(/Seed directory.*does not exist/)
      end
    end
  end

  describe "#load_seed_file" do
    context "when loading by class name" do
      before do
        SeedBuilderUser.delete_all
        loader.load_seed_file("create_users")
      end

      it "loads the specific seed file" do
        expect(SeedBuilderUser.count).to eq 1
        expect(SeedBuilderUser.first.email).to eq "test@example.com"
      end
    end

    context "when loading by full name" do
      before do
        SeedBuilderUser.delete_all
        loader.load_seed_file("20241206200111_create_users")
      end

      it "loads the specific seed file" do
        expect(SeedBuilderUser.count).to eq 1
      end
    end

    context "when loading by timestamp" do
      before do
        SeedBuilderUser.delete_all
        loader.load_seed_file("20241206200111")
      end

      it "loads the specific seed file" do
        expect(SeedBuilderUser.count).to eq 1
      end
    end

    context "when seed file does not exist" do
      let(:log_output) { StringIO.new }
      let(:test_logger) { Logger.new(log_output) }

      before do
        allow(Rails).to receive(:logger).and_return(test_logger)
        # Reset SeedBuilder logger to pick up the stubbed Rails.logger
        SeedBuilder.instance_variable_set(:@logger, nil) if SeedBuilder.instance_variable_defined?(:@logger)
      end

      it "outputs an error message" do
        loader.load_seed_file("nonexistent_seed")
        expect(log_output.string).to match(/Seed file 'nonexistent_seed' not found/)
      end

      it "does not raise an error" do
        expect { loader.load_seed_file("nonexistent_seed") }.not_to raise_error
      end
    end

    context "when multiple seed files match the name" do
      let(:seed_path_1) { File.expand_path("../../tmp/rspec/db/seeds/20241206200111_create_users.rb", __FILE__) }
      let(:seed_path_2) { File.expand_path("../../tmp/rspec/db/seeds/20241206200112_create_users.rb", __FILE__) }
      let(:log_output) { StringIO.new }
      let(:test_logger) { Logger.new(log_output) }

      before do
        allow(Rails).to receive(:logger).and_return(test_logger)
        # Reset SeedBuilder logger to pick up the stubbed Rails.logger
        SeedBuilder.instance_variable_set(:@logger, nil) if SeedBuilder.instance_variable_defined?(:@logger)
        FileUtils.mkdir_p(File.dirname(seed_path_1))
        File.write(seed_path_1, "class CreateUsers; def change; end; end")
        File.write(seed_path_2, "class CreateUsers; def change; end; end")
        SeedBuilder.configure do |config|
          config.seeds_full_path = File.dirname(seed_path_1)
        end
      end

      after do
        File.delete(seed_path_1) if File.exist?(seed_path_1)
        File.delete(seed_path_2) if File.exist?(seed_path_2)
      end

      it "outputs an error message listing all matching files" do
        loader.load_seed_file("create_users")
        expect(log_output.string).to match(
          /Multiple seed files match 'create_users':.*20241206200111_create_users.*20241206200112_create_users.*Please be more specific/m
        )
      end

      it "does not raise an error" do
        expect { loader.load_seed_file("create_users") }.not_to raise_error
      end

      it "works when using the full name with timestamp" do
        SeedBuilderUser.delete_all
        loader.load_seed_file("20241206200111_create_users")
        expect(log_output.string).not_to match(/Multiple seed files/)
        expect(SeedBuilderUser.count).to eq 0 # The seed doesn't actually create anything, just checks it runs
      end
    end

    context "when seeds directory does not exist" do
      let(:log_output) { StringIO.new }
      let(:test_logger) { Logger.new(log_output) }

      before do
        allow(Rails).to receive(:logger).and_return(test_logger)
        # Reset SeedBuilder logger to pick up the stubbed Rails.logger
        SeedBuilder.instance_variable_set(:@logger, nil) if SeedBuilder.instance_variable_defined?(:@logger)
        SeedBuilder.configure do |config|
          config.seeds_full_path = "/non/existent/path"
        end
      end

      it "outputs an error message" do
        loader.load_seed_file("create_users")
        expect(log_output.string).to match(/Seed directory.*does not exist/)
      end

      it "does not raise an error" do
        expect { loader.load_seed_file("create_users") }.not_to raise_error
      end
    end

    context "when seed file has invalid format" do
      let(:invalid_seed_path) { File.expand_path("../../tmp/rspec/invalid_seed.rb", __FILE__) }
      let(:log_output) { StringIO.new }
      let(:test_logger) { Logger.new(log_output) }

      before do
        allow(Rails).to receive(:logger).and_return(test_logger)
        # Reset SeedBuilder logger to pick up the stubbed Rails.logger
        SeedBuilder.instance_variable_set(:@logger, nil) if SeedBuilder.instance_variable_defined?(:@logger)
        FileUtils.mkdir_p(File.dirname(invalid_seed_path))
        File.write(invalid_seed_path, "class InvalidSeed; end")
        SeedBuilder.configure do |config|
          config.seeds_full_path = File.dirname(invalid_seed_path)
        end
      end

      after do
        File.delete(invalid_seed_path) if File.exist?(invalid_seed_path)
      end

      it "outputs an error message" do
        loader.load_seed_file("invalid_seed")
        expect(log_output.string).to match(/Invalid seed file format/)
      end

      it "does not raise an error" do
        expect { loader.load_seed_file("invalid_seed") }.not_to raise_error
      end
    end

    context "when seed class does not respond to change" do
      let(:invalid_seed_path) { File.expand_path("../../tmp/rspec/db/seeds/20241206200112_no_change.rb", __FILE__) }

      before do
        FileUtils.mkdir_p(File.dirname(invalid_seed_path))
        File.write(invalid_seed_path, <<~RUBY)
          class NoChange
            # Does not have change method
          end
        RUBY
        SeedBuilder.configure do |config|
          config.seeds_full_path = File.dirname(invalid_seed_path)
        end
      end

      after do
        File.delete(invalid_seed_path) if File.exist?(invalid_seed_path)
      end

      it "raises an error" do
        expect { loader.load_seed_file("no_change") }.to raise_error(/does not respond to :change/)
      end
    end

    context "when seed raises RecordInvalid" do
      let(:invalid_seed_path) { File.expand_path("../../tmp/rspec/db/seeds/20241206200113_invalid_record.rb", __FILE__) }
      let(:log_output) { StringIO.new }
      let(:test_logger) { Logger.new(log_output) }

      before do
        allow(Rails).to receive(:logger).and_return(test_logger)
        # Reset SeedBuilder logger to pick up the stubbed Rails.logger
        SeedBuilder.instance_variable_set(:@logger, nil) if SeedBuilder.instance_variable_defined?(:@logger)
        # Add a validation to SeedBuilderUser to make save! fail
        SeedBuilderUser.class_eval do
          validates :email, presence: true
        end

        FileUtils.mkdir_p(File.dirname(invalid_seed_path))
        File.write(invalid_seed_path, <<~RUBY)
          class InvalidRecord
            def change
              user = SeedBuilderUser.new # Missing required email
              user.save! # This will fail validation
            end
          end
        RUBY
        SeedBuilder.configure do |config|
          config.seeds_full_path = File.dirname(invalid_seed_path)
        end
      end

      after do
        File.delete(invalid_seed_path) if File.exist?(invalid_seed_path)
        # Remove the validation
        SeedBuilderUser.reset_column_information
      end

      it "outputs error message and re-raises" do
        expect { loader.load_seed_file("invalid_record") }.to raise_error(ActiveRecord::RecordInvalid)
        expect(log_output.string).to match(/Seeding.*failed/)
      end
    end
  end
end
