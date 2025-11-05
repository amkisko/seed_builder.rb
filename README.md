# seed_builder.rb

[![Gem Version](https://badge.fury.io/rb/seed_builder.svg)](https://badge.fury.io/rb/seed_builder) [![Test Status](https://github.com/amkisko/seed_builder.rb/actions/workflows/test.yml/badge.svg)](https://github.com/amkisko/seed_builder.rb/actions/workflows/test.yml) [![codecov](https://codecov.io/gh/amkisko/seed_builder.rb/graph/badge.svg?token=57R6OHOJDQ)](https://codecov.io/gh/amkisko/seed_builder.rb)

Seed builder for ActiveRecord. Includes seeds loader and generator.

Sponsored by [Kisko Labs](https://www.kiskolabs.com).

<a href="https://www.kiskolabs.com">
  <img src="kisko.svg" width="200" alt="Sponsored by Kisko Labs" />
</a>

## Installation

Using Bundler:

```sh
bundle add seed_builder
```

Using RubyGems:

```sh
gem install seed_builder
```

## Gemfile

```ruby
gem "seed_builder"
```

## Usage

### Run seeds

Run all seeds:

```sh
bin/rails db:seed
```

Or in code:

```ruby
Rails.application.load_seed
```

Run a specific seed file:

```sh
bin/rails seed:run[create_users]
```

You can specify the seed name in different formats:
- Class name: `create_users` (matches `20241206200111_create_users.rb`)
- Full name: `20241206200111_create_users`
- Timestamp: `20241206200111`

**Note:** If multiple seed files match the same name, you'll be prompted to use the full name with timestamp to avoid ambiguity. For example, if both `20241206200111_create_users.rb` and `20241206200112_create_users.rb` exist, running `bin/rails seed:run[create_users]` will show an error listing all matches and ask you to be more specific.

### Generate seed file

```sh
bin/rails g seed create_users
```

## Configuration

### Load default seeds.rb file

By default seed file `db/seeds.rb` is loaded.

To turn off loading default seeds.rb file:

```ruby
SeedBuilder.config.load_default_seeds = false
```

### Set seed directory

Absolute path will be resolved by using `Rails.root`.

```ruby
SeedBuilder.config.seeds_path = "db/seeds"
```

### Turn off test script generation

```ruby
SeedBuilder.config.generate_spec = false
```

### Turn off loader usage for ActiveRecord

```ruby
SeedBuilder.config.use_seed_loader = false
```

### Set custom logger

By default, SeedBuilder uses `Rails.logger` (or falls back to `Logger.new($stdout)` if Rails is not available). All seed-related log messages are tagged with `[seed]`.

To use a custom logger:

```ruby
SeedBuilder.config.logger = MyCustomLogger.new
```

The logger will be automatically wrapped with `ActiveSupport::TaggedLogging` if it doesn't already support tagging, ensuring all seed messages are tagged with `[seed]`.

## Specification checklist

- [x] User can generate seed file under `db/seeds` directory with common format
- [x] User can generate seed file with test script included
- [x] User can run all seeds
- [x] User can run specific seed file

## Limitations & explanations

- Gem patches `ActiveRecord::Tasks::DatabaseTasks.seed_loader` to have custom loader
- ActiveRecord migrations generator is used to generate seed files
- Seeded data is not reversible, there is no point to implement it as logic can be complex and operations on data might lead to irreversible changes
- Seed file is not a migration, although as good practice is to keep it idempotent, e.g. by checking uniqueness of seeded records

## Development

```bash
# Install dependencies
bundle install
bundle exec appraisal install

# Run tests for current Rails version
bundle exec rspec

# Run tests for all Rails versions (6.1, 7.2, 8.1)
bin/appraisals

# Run tests for specific Rails version
bin/appraisals rails-7.2

# Run tests for multiple versions
bin/appraisals rails-7.2 rails-8.1

# Or use appraisal directly
bundle exec appraisal rails-7.2 rspec

# Run linter
bundle exec standardrb --fix

# Check type signatures
bundle exec rbs validate
```

### Development: Using from Local Repository

When developing the gem or testing changes in your application, you can point your Gemfile to a local path:

```ruby
# In your application's Gemfile
gem "seed_builder", path: "../seed_builder.rb"
```

Then run:

```bash
bundle install
```

**Note:** When using `path:` in your Gemfile, Bundler will use the local gem directly. Changes you make to the gem code will be immediately available in your application without needing to rebuild or reinstall the gem. This is ideal for development and testing.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/amkisko/seed_builder.rb>

Contribution policy:
- New features are not necessarily added to the gem
- Pull request should have test coverage for affected parts
- Pull request should have changelog entry

Review policy:
- It might take up to 2 calendar weeks to review and merge critical fixes
- It might take up to 6 calendar months to review and merge pull request
- It might take up to 1 calendar year to review an issue

## Publishing

Prefer using script `usr/bin/release.sh`, it will ensure that repository is synced and after publishing gem will create a tag.

```sh
GEM_VERSION=$(grep -Eo "VERSION\s*=\s*\".+\"" lib/seed_builder.rb  | grep -Eo "[0-9.]{5,}")
rm seed_builder-*.gem
gem build seed_builder.gemspec
gem push seed_builder-$GEM_VERSION.gem
git tag $GEM_VERSION && git push --tags
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
