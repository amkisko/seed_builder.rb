module SeedBuilder
  class Loader
    def load_seed
      initial_logger = Rails.logger

      Rails.logger = Logger.new($stdout)
      Rails.logger.level = Logger::INFO

      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.descendants.each(&:reset_column_information)

      default_seeds_rb = SeedBuilder.config.default_seeds_full_path
      if File.exist?(default_seeds_rb) && SeedBuilder.config.load_default_seeds?
        started_at = Time.current
        puts "== #{SeedBuilder.config.default_seeds_path}: seeding"
        require default_seeds_rb
        puts "== #{SeedBuilder.config.default_seeds_path}: seeded (#{(Time.current - started_at).round(4)}s)"
      end

      base_path = SeedBuilder.config.seeds_full_path
      if File.exist?(base_path) && SeedBuilder.config.load_seeds?
        Dir[SeedBuilder.config.seeds_path_glob]
          .map { |f| File.basename(f, ".*") }
          .each do |seed_path|
            require "#{base_path}/#{seed_path}.rb"
            timestamp, klass_name = seed_path.scan(/^([0-9]+)_(.+)$/).first
            next if klass_name.blank?

            klass = klass_name.camelize.constantize
            puts "== #{timestamp} #{klass.name}: seeding"
            started_at = Time.current
            seed_instance = klass.new
            if seed_instance.respond_to?(:change)
              seed_instance.change
            else
              raise "Seed #{klass.name} does not respond to :change"
            end
            puts "== #{timestamp} #{klass.name}: seeded (#{(Time.current - started_at).round(4)}s)"
          rescue ActiveRecord::RecordInvalid => e
            puts "Seeding #{klass.name} failed: #{e.record.errors.full_messages}"
            raise e
          end
      else
        puts "Seed directory #{base_path} does not exist"
      end

      Rails.logger = initial_logger
    end
  end
end
