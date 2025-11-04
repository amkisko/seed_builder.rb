namespace :seed do
  desc "Run a specific seed file by name"
  task :run, [:seed_name] => :environment do |_task, args|
    if args[:seed_name].nil? || args[:seed_name].empty?
      puts "Usage: bin/rails seed:run[SEED_NAME]"
      puts ""
      puts "Run a specific seed file by name."
      puts ""
      puts "Examples:"
      puts "  bin/rails seed:run[create_users]"
      puts "  bin/rails seed:run[20241206200111_create_users]"
      puts "  bin/rails seed:run[20241206200111]"
      puts ""
      puts "Note: If multiple seed files match the name, use the full name with"
      puts "      timestamp to avoid ambiguity (e.g., 20241206200111_create_users)."
      exit 1
    end

    loader = SeedBuilder::Loader.new
    loader.load_seed_file(args[:seed_name])
  end
end

