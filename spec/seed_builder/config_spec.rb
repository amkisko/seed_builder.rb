require "spec_helper"

# Define Rails module if not already defined
unless defined?(Rails)
  module Rails
    class << self
      attr_accessor :root, :env, :logger
    end
  end
end

describe SeedBuilder::Config do
  subject(:config) { described_class.new }

  before do
    allow(Rails).to receive(:root).and_return(rails_root)
  end

  it "has default seeds path" do
    expect(config.seeds_path).to eq "db/seeds"
  end

  it "has default load_seeds" do
    expect(config.load_seeds?).to be true
  end

  it "has default load_default_seeds" do
    expect(config.load_default_seeds?).to be true
  end

  it "has default generate_spec" do
    expect(config.generate_spec?).to be true
  end

  it "has default seeds_full_path" do
    expect(config.seeds_full_path).to eq Rails.root.join("db/seeds")
  end

  it "has default seeds_path_glob" do
    expect(config.seeds_path_glob).to eq Rails.root.join("db/seeds/*.rb").to_s
  end

  it "allows setting a custom logger" do
    custom_logger = Logger.new($stdout)
    config.logger = custom_logger
    expect(config.logger).to eq custom_logger
  end
end
