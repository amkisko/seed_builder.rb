require "rails/generators"
require "rails/generators/active_record"
require "rails/generators/active_record/migration/migration_generator"

class SeedGenerator < ActiveRecord::Generators::MigrationGenerator
  source_root File.expand_path("../templates", __FILE__)

  def create_migration_file
    set_local_assigns!
    validate_file_name!
    migration_template "seed.rb", "#{SeedBuilder.config.seeds_path}/#{file_name}.rb"
  end
end
