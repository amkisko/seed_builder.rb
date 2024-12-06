require "spec_helper"

describe SeedBuilder::Config do
  subject(:config) { described_class.new }

  before do
    allow(Rails).to receive(:root).and_return(rails_root)
  end

  it "has default seeds path" do
    expect(config.seeds_relative_path).to eq "db/seeds"
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

  it "has default seeds_path" do
    expect(config.seeds_path).to eq Rails.root.join("db/seeds")
  end

  it "has default seeds_path_glob" do
    expect(config.seeds_path_glob).to eq Rails.root.join("db/seeds/*.rb").to_s
  end
end
