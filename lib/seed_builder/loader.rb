module SeedBuilder
  class Loader
    def load_seed
      prepare_active_record

      default_seeds_rb = SeedBuilder.config.default_seeds_full_path
      if File.exist?(default_seeds_rb) && SeedBuilder.config.load_default_seeds?
        started_at = Time.current
        logger.tagged("seed") do
          logger.info "== #{SeedBuilder.config.default_seeds_path}: seeding"
        end
        load default_seeds_rb
        logger.tagged("seed") do
          logger.info "== #{SeedBuilder.config.default_seeds_path}: seeded (#{(Time.current - started_at).round(4)}s)"
        end
      end

      base_path = SeedBuilder.config.seeds_full_path
      if File.exist?(base_path) && SeedBuilder.config.load_seeds?
        Dir[SeedBuilder.config.seeds_path_glob]
          .map { |f| File.basename(f, ".*") }
          .each do |seed_path|
            load "#{base_path}/#{seed_path}.rb"
            timestamp, klass_name = seed_path.scan(/^([0-9]+)_(.+)$/).first
            next if klass_name.blank?

            execute_seed_class(klass_name, timestamp)
          end
      else
        logger.tagged("seed") do
          logger.warn "Seed directory #{base_path} does not exist"
        end
      end
    end

    def load_seed_file(seed_name)
      prepare_active_record

      base_path = SeedBuilder.config.seeds_full_path
      unless File.exist?(base_path)
        logger.tagged("seed") do
          logger.warn "Seed directory #{base_path} does not exist"
        end
        return
      end

      # Find the seed file by name
      # Supports: "create_users", "20241206200111_create_users", "20241206200111"
      result = find_seed_file(base_path, seed_name)

      if result.nil?
        logger.tagged("seed") do
          logger.warn "Seed file '#{seed_name}' not found in #{base_path}"
        end
        return
      elsif result == :ambiguous
        matches = find_seed_file_matches(base_path, seed_name)
        logger.tagged("seed") do
          logger.warn "Multiple seed files match '#{seed_name}':"
          matches.each do |file|
            logger.warn "  - #{File.basename(file, ".*")}"
          end
          logger.warn "Please be more specific using the full name with timestamp (e.g., 20241206200111_create_users)"
        end
        return
      end

      seed_file = result

      seed_path = File.basename(seed_file, ".*")
      timestamp, klass_name = seed_path.scan(/^([0-9]+)_(.+)$/).first

      if klass_name.blank?
        logger.tagged("seed") do
          logger.warn "Invalid seed file format: #{seed_path}. Expected format: TIMESTAMP_CLASS_NAME.rb"
        end
        return
      end

      load seed_file
      execute_seed_class(klass_name, timestamp, seed_name)
    end

    private

    def logger
      SeedBuilder.logger
    end

    def prepare_active_record
      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.descendants.each(&:reset_column_information)
    end

    def execute_seed_class(klass_name, timestamp, seed_name = nil)
      klass = klass_name.camelize.constantize
      klass_name_display = klass.name
      logger.tagged("seed") do
        logger.info "== #{timestamp} #{klass_name_display}: seeding"
      end
      started_at = Time.current
      seed_instance = klass.new
      if seed_instance.respond_to?(:change)
        seed_instance.change
      else
        raise "Seed #{klass_name_display} does not respond to :change"
      end
      logger.tagged("seed") do
        logger.info "== #{timestamp} #{klass_name_display}: seeded (#{(Time.current - started_at).round(4)}s)"
      end
    rescue ActiveRecord::RecordInvalid => e
      klass_name_display = defined?(klass) ? klass.name : (klass_name&.camelize || seed_name || klass_name)
      logger.tagged("seed") do
        logger.error "Seeding #{klass_name_display} failed: #{e.record.errors.full_messages}"
      end
      raise e
    rescue => e
      logger.tagged("seed") do
        logger.error "Error loading seed: #{e.message}"
      end
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
