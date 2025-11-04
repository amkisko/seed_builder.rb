# CHANGELOG

## 1.3.0 (2025-11-04)

- Replace `puts` statements with `Rails.logger` for proper logging integration
- Add tagged logging with `seed` tag for all seed-related log messages
- Add `logger` configuration option to allow custom logger setup via `SeedBuilder.config.logger = custom_logger`
- Fix seed file loading to use `load` instead of `require` to ensure files are re-executed on each seed run
- Logger automatically detects if `Rails.logger` already supports tagging to avoid double-wrapping
- Add ability to run specific seed files on demand using `bin/rails seed:run[SEED_NAME]`
- Add `load_seed_file` method to `SeedBuilder::Loader` for loading individual seeds
- Add ambiguous match detection: when multiple seed files match the same name, the loader will show an error listing all matches and prompt the user to use the full name with timestamp
- Patch `Rails.application.load_seed` to use SeedBuilder loader via Railtie integration

## 1.2.1

- Fix seed files to be loaded as `.rb` files
- Add `default_seeds_full_path` config option to control default seeds full path
- Fix files loading using absolute paths
- Improve test coverage

## 1.2.0

- Automatically configure loader for Rails seeds
- Add `use_seed_loader` config option to control loader usage

## 1.1.0

- Fix `seeds_path` to be relative to Rails root
- Improve test coverage for generator

## 1.0.1

- Fix boolean config options to properly handle `nil` and `false` values

## 1.0.0

- Initial version
