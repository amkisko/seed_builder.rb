module SeedBuilder
  class Config
    attr_writer :default_seeds_path
    def default_seeds_path
      @default_seeds_path ||= "db/seeds.rb"
    end

    attr_writer :default_seeds_full_path
    def default_seeds_full_path
      @default_seeds_full_path ||= Rails.root.join(default_seeds_path)
    end

    attr_writer :seeds_path
    def seeds_path
      @seeds_path ||= "db/seeds"
    end

    attr_writer :seeds_full_path
    def seeds_full_path
      @seeds_full_path ||= Rails.root.join(seeds_path)
    end

    def seeds_path_glob
      "#{seeds_full_path}/*.rb"
    end

    attr_writer :load_default_seeds
    def load_default_seeds?
      @load_default_seeds.nil? || @load_default_seeds
    end

    attr_writer :load_seeds
    def load_seeds?
      @load_seeds.nil? || @load_seeds
    end

    attr_writer :generate_spec
    def generate_spec?
      @generate_spec.nil? || @generate_spec
    end

    attr_writer :use_seed_loader
    def use_seed_loader?
      @use_seed_loader.nil? || @use_seed_loader
    end

    attr_accessor :logger
  end
end
