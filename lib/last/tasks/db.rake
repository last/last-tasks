namespace :db do
  # Database
  #
  task create: :environment do
    puts "Creating databases..."
    puts %x(
      createdb -e #{ENV['APP_NAME']}_development && \
      createdb -e #{ENV['APP_NAME']}_test
    )
  end

  task drop: :environment do
    puts "Dropping databases..."
    puts %x(
      dropdb -e --if-exists #{ENV['APP_NAME']}_development && \
      dropdb -e --if-exists #{ENV['APP_NAME']}_test
    )
  end

  task recreate: :environment do
    Rake::Task['db:drop'].invoke && Rake::Task['db:create'].invoke
  end

  # Console
  #
  task console: :application do
    exec("psql #{ENV['APP_NAME']}_#{ENV['RACK_ENV']}")
  end

  # Migration
  #
  task migrate: :application do
    puts "Migrating #{ENV['RACK_ENV']} database..."

    require 'sequel/extensions/migration'

    database_is_defined?

    Sequel::Migrator.apply(Database, 'db/migrations')

    version = Database[:schema_info].first[:version]

    puts "Migrated #{ENV['RACK_ENV']} database to version #{version}."
  end

  task rollback: :application do
    require 'sequel/extensions/migration'

    database_is_defined?

    version = ((row = Database[:schema_info].first) ? row[:version] : 1) - 1

    puts "Rolling back database to version #{version}"

    Sequel::Migrator.apply(Database, 'db/migrations', version)
  end

  task reset: :environment do
    Rake::Task['db:recreate'].invoke && Rake::Task['db:migrate'].invoke
  end

  # Backup
  #
  task dump: :application do
    database_is_defined?
    `sequel -d #{Database.url} > db/schema.rb`
    `pg_dump --schema-only #{Database.url} > db/schema.sql`
  end
end

private

def database_is_defined?
  unless defined?(Database) && !Database.nil?
    puts "Database must be initialized."
    exit 1
  end
end
