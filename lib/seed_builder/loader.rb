module SeedBuilder
  class Loader
    def load_seed
      with_rails_logger do
        prepare_active_record

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

              execute_seed_class(klass_name, timestamp)
            end
        else
          puts "Seed directory #{base_path} does not exist"
        end
      end
    end

    def load_seed_file(seed_name)
      with_rails_logger do
        prepare_active_record

        base_path = SeedBuilder.config.seeds_full_path
        unless File.exist?(base_path)
          puts "Seed directory #{base_path} does not exist"
          return
        end

        # Find the seed file by name
        # Supports: "create_users", "20241206200111_create_users", "20241206200111"
        result = find_seed_file(base_path, seed_name)

        if result.nil?
          puts "Seed file '#{seed_name}' not found in #{base_path}"
          return
        elsif result == :ambiguous
          matches = find_seed_file_matches(base_path, seed_name)
          puts "Multiple seed files match '#{seed_name}':"
          matches.each do |file|
            puts "  - #{File.basename(file, ".*")}"
          end
          puts "Please be more specific using the full name with timestamp (e.g., 20241206200111_create_users)"
          return
        end

        seed_file = result

        seed_path = File.basename(seed_file, ".*")
        timestamp, klass_name = seed_path.scan(/^([0-9]+)_(.+)$/).first

        if klass_name.blank?
          puts "Invalid seed file format: #{seed_path}. Expected format: TIMESTAMP_CLASS_NAME.rb"
          return
        end

        require seed_file
        execute_seed_class(klass_name, timestamp, seed_name)
      end
    end

    private

    def with_rails_logger
      initial_logger = Rails.logger
      Rails.logger = Logger.new($stdout)
      Rails.logger.level = Logger::INFO
      yield
    ensure
      Rails.logger = initial_logger
    end

    def prepare_active_record
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.descendants.each(&:reset_column_information)
    end

    def execute_seed_class(klass_name, timestamp, seed_name = nil)
      klass = klass_name.camelize.constantize
      klass_name_display = klass.name
      puts "== #{timestamp} #{klass_name_display}: seeding"
      started_at = Time.current
      seed_instance = klass.new
      if seed_instance.respond_to?(:change)
        seed_instance.change
      else
        raise "Seed #{klass_name_display} does not respond to :change"
      end
      puts "== #{timestamp} #{klass_name_display}: seeded (#{(Time.current - started_at).round(4)}s)"
    rescue ActiveRecord::RecordInvalid => e
      klass_name_display = defined?(klass) ? klass.name : (klass_name&.camelize || seed_name || klass_name)
      puts "Seeding #{klass_name_display} failed: #{e.record.errors.full_messages}"
      raise e
    rescue => e
      puts "Error loading seed: #{e.message}"
      raise e
    end

    def find_seed_file(base_path, seed_name)
      # Try exact match first
      exact_match = File.join(base_path, "#{seed_name}.rb")
      return exact_match if File.exist?(exact_match)

      # Collect all matching files
      matches = find_seed_file_matches(base_path, seed_name)

      # Return appropriate result based on number of matches
      case matches.length
      when 0
        nil
      when 1
        matches.first
      else
        :ambiguous
      end
    end

    def find_seed_file_matches(base_path, seed_name)
      matches = []
      Dir[SeedBuilder.config.seeds_path_glob].each do |file|
        basename = File.basename(file, ".*")
        # Match by class name (e.g., "create_users")
        if basename.end_with?("_#{seed_name}") || basename == seed_name
          matches << file
        # Match by timestamp (e.g., "20241206200111")
        elsif basename.start_with?("#{seed_name}_")
          matches << file
        end
      end
      matches
    end
  end
end
