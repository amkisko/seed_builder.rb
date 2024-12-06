require "spec_helper"

describe SeedBuilder do
  let(:gem_specification) { Gem::Specification.load(File.expand_path("../../seed_builder.gemspec", __FILE__)) }

  it "has a version number" do
    expect(described_class::VERSION).to eq gem_specification.version.to_s
  end

  let(:changelog_file) { File.expand_path("../../CHANGELOG.md", __FILE__) }
  it "has changelog for the version" do
    expect(File.exist?(changelog_file)).to be true
    expect(File.read(changelog_file)).to include("# #{gem_specification.version.to_s}")
  end

  let(:license_file) { File.expand_path("../../LICENSE.md", __FILE__) }
  it "has license" do
    expect(File.exist?(license_file)).to be true
  end

  let(:readme_file) { File.expand_path("../../README.md", __FILE__) }
  it "has readme" do
    expect(File.exist?(readme_file)).to be true
  end
end
