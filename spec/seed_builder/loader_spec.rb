require "spec_helper"

class SeedBuilderUser < ActiveRecord::Base; end
class SeedUser < SeedBuilderUser; end

describe SeedBuilder::Loader do
  subject(:loader) { described_class.new }

  describe "#load_seed" do
    let(:load_default_seeds) { true }
    let(:load_seeds) { true }
    let(:logger) { Logger.new($stdout) }

    before do
      allow(Rails).to receive(:root).and_return(rails_root)
      allow(Rails).to receive(:env).and_return(rails_env)
      allow(Rails).to receive(:logger).and_return(logger)
      allow(Rails).to receive(:logger=)

      SeedBuilder.configure do |config|
        config.seeds_path = File.expand_path("../../fixtures/seeds", __FILE__)
        config.default_seeds_path = File.expand_path("../../fixtures/seeds.rb", __FILE__)
        config.load_default_seeds = load_default_seeds
        config.load_seeds = load_seeds
      end
      loader.load_seed
    end

    it "loads the seeds" do
      expect(SeedUser.count).to eq 1
    end
  end
end
