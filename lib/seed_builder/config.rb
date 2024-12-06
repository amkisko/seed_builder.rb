module SeedBuilder
  class Config
    attr_writer :default_seeds_path
    def default_seeds_path
      @default_seeds_path ||= Rails.root.join("db/seeds.rb")
    end

    attr_writer :seeds_path
    def seeds_path
      @seeds_path ||= Rails.root.join(seeds_relative_path)
    end

    def seeds_path_glob
      "#{seeds_path}/*.rb"
    end

    attr_writer :seeds_relative_path
    def seeds_relative_path
      @seeds_relative_path ||= "db/seeds"
    end

    attr_writer :load_default_seeds
    def load_default_seeds?
      @load_default_seeds ||= true
    end

    attr_writer :load_seeds
    def load_seeds?
      @load_seeds ||= true
    end

    attr_writer :generate_spec
    def generate_spec?
      @generate_spec ||= true
    end
  end
end
