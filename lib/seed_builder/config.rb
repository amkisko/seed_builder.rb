module SeedBuilder
  class Config
    attr_writer :default_seeds_path
    def default_seeds_path
      @default_seeds_path ||= Rails.root.join("db/seeds.rb")
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
      @load_default_seeds.nil? ? true : @load_default_seeds
    end

    attr_writer :load_seeds
    def load_seeds?
      @load_seeds.nil? ? true : @load_seeds
    end

    attr_writer :generate_spec
    def generate_spec?
      @generate_spec.nil? ? true : @generate_spec
    end
  end
end
