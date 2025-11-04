Gem::Specification.new do |gem|
  gem.name = "seed_builder"
  gem.version = File.read(File.expand_path("../lib/seed_builder.rb", __FILE__)).match(/VERSION\s*=\s*"(.*?)"/)[1]

  repository_url = "https://github.com/amkisko/seed_builder.rb"
  root_files = %w[CHANGELOG.md LICENSE.md README.md]
  root_files << "#{gem.name}.gemspec"

  gem.license = "MIT"

  gem.platform = Gem::Platform::RUBY

  gem.authors = ["Andrei Makarov"]
  gem.email = ["contact@kiskolabs.com"]
  gem.homepage = repository_url
  gem.summary = "Seed builder with loader and generator"
  gem.description = "Extension for ActiveRecord to organize seeds in a directory and generate them as migrations"
  gem.metadata = {
    "homepage" => repository_url,
    "source_code_uri" => repository_url,
    "bug_tracker_uri" => "#{repository_url}/issues",
    "changelog_uri" => "#{repository_url}/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  gem.files = `git ls-files`.split("\n").reject { |f| f.match?(%r{^(test|spec|features)/}) }
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  gem.required_ruby_version = ">= 3"
  gem.require_paths = ["lib"]

  gem.add_dependency "rails", ">= 6.1", "< 8.2"
  gem.add_dependency "activerecord", ">= 6.1", "< 8.2"

  gem.add_development_dependency "bundler", "~> 2"
  gem.add_development_dependency "rspec", "~> 3"
  gem.add_development_dependency "rspec_junit_formatter", "~> 0.6"
  gem.add_development_dependency "simplecov", "~> 0.21"
  gem.add_development_dependency "simplecov-cobertura", "~> 2"
  gem.add_development_dependency "sqlite3", "~> 2.4"
  gem.add_development_dependency "standard", "~> 1.0"
  gem.add_development_dependency "rbs", "~> 3.0"
  gem.add_development_dependency "appraisal", "~> 2.4"
end
