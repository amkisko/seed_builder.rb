# seed_builder.rb

[![Gem Version](https://badge.fury.io/rb/seed_builder.svg)](https://badge.fury.io/rb/seed_builder) [![Test Status](https://github.com/amkisko/seed_builder.rb/actions/workflows/test.yml/badge.svg)](https://github.com/amkisko/seed_builder.rb/actions/workflows/test.yml) [![codecov](https://codecov.io/gh/amkisko/seed_builder.rb/graph/badge.svg?token=57R6OHOJDQ)](https://codecov.io/gh/amkisko/seed_builder.rb)

Seed builder for ActiveRecord. Includes seeds loader and generator.

Sponsored by [Kisko Labs](https://www.kiskolabs.com).

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

```sh
bin/rails db:seed
```

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
SeedBuilder.config.seeds_relative_path = "db/seeds"
```

### Turn off test script generation

```ruby
SeedBuilder.config.generate_spec = false
```

## Specification checklist

- [x] User can generate seed file under `db/seeds` directory with common format
- [x] User can generate seed file with test script included
- [x] User can run all seeds
- [ ] User can run specific seed file

## Limitations & explanations

- Gem patches `ActiveRecord::Tasks::DatabaseTasks.seed_loader` to have custom loader
- ActiveRecord migrations generator is used to generate seed files
- Seeded data is not reversible, there is no point to implement it as logic can be complex and operations on data might lead to irreversible changes
- Seed file is not a migration, although as good practice is to keep it idempotent, e.g. by checking uniqueness of seeded records

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/amkisko/seed_builder.rb>

Contribution policy:

- New features are not necessarily added to the gem
- Pull request should have test coverage for affected parts
- Pull request should have changelog entry
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
