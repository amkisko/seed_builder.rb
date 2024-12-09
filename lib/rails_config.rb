if Object.const_defined?(:ActiveRecord) && SeedBuilder.config.use_seed_loader?
  ActiveRecord::Tasks::DatabaseTasks.seed_loader = SeedBuilder::Loader.new
end
