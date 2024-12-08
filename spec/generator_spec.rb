require "spec_helper"

require "generators/seed_generator"

describe SeedGenerator, type: :generator do
  include FileUtils

  subject(:generator) { described_class.start params }
  let(:destination_root) { File.expand_path("../../tmp/rspec", __FILE__) }
  let(:seeds_path) { rails_root.join("db/seeds") }

  let(:seed_name) { "create_users" }
  let(:params) { [seed_name] }

  let(:created_files) { Dir["#{seeds_path}/*_#{seed_name}.rb"] }
  let(:file_contents) { File.readlines(created_files.first).map(&:strip).reject(&:blank?) }

  before do
    mkdir_p destination_root

    allow(SeedBuilder.config).to receive(:seeds_path).and_return(seeds_path)
    allow(Rails).to receive(:root).and_return(rails_root(destination_root))
  end

  after do
    rm_rf destination_root
  end

  it "creates a migration file" do
    generator

    expect(created_files).not_to be_empty
    expect(file_contents).to include("class CreateUsers")
    expect(file_contents).not_to include("RSpec.describe CreateUsers")
  end

  context "when generate_spec is false" do
    before do
      allow(SeedBuilder.config).to receive(:generate_spec?).and_return(false)
    end

    it "does not create a spec file" do
      generator

      expect(created_files).not_to be_empty
      expect(file_contents).to include("class CreateUsers")
      expect(file_contents).not_to include("RSpec.describe CreateUsers")
    end
  end
end
