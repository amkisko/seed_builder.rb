if Object.const_defined?(:ActiveRecord)
  ActiveRecord::Tasks::DatabaseTasks.seed_loader = SeedBuilder::Loader.new
end
