require "spec_helper"

require "generators/seed_generator"

describe SeedGenerator, type: :generator do
  include FileUtils

  subject(:generator) { described_class.start params }
  let(:destination_root) { File.expand_path("../../tmp/rspec", __FILE__) }

  let(:params) { ["create_users"] }

  before do
    mkdir_p destination_root

    allow(Rails).to receive(:root).and_return(rails_root(destination_root))
  end

  after do
    rm_rf destination_root
  end

  it "creates a migration file" do
    generator
    seed_files = Dir[rails_root.join("db/seeds/*_create_users.rb")]
    expect(seed_files).not_to be_empty
  end
end
