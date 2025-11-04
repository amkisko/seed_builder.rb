module SeedBuilder
  class Railtie < ::Rails::Railtie
    config.to_prepare do
      if SeedBuilder.config.use_seed_loader?
        # Patch Rails.application.load_seed to use our custom loader
        Rails.application.class.class_eval do
          define_method(:load_seed) do
            loader = SeedBuilder::Loader.new
            loader.load_seed
          end
        end
      end
    end
  end
end
