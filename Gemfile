source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem 'listen'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  # gem 'spring-watcher-listen'

  # Preview mail in the browser instead of sending.
  gem 'letter_opener'
  # A web interface for browsing Ruby on Rails sent emails
  gem 'letter_opener_web'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gem 'font_awesome5_rails'

gem 'bootstrap_form'
gem 'simple_calendar', '2.3.0'
gem 'devise'
gem 'devise-i18n'
gem 'audited'
gem 'capture_stdout'
gem 'will_paginate'
gem 'will_paginate-bootstrap4'
gem 'pundit'

# PDF
gem 'prawn'
gem 'prawn-table'

# XLSX sheet
gem 'spreadsheet'
gem 'yaml_db'

# iCal
gem 'icalendar'

# The `content_tag_for` method has been removed from Rails. To continue using it, add the `record_tag_helper` gem to your Gemfile:
#gem 'record_tag_helper'

# Access-Control-Allow-Origin (pour l'APP React)
gem 'rack-cors'

# Sucker Punch is a single-process Ruby asynchronous processing library.
gem 'sucker_punch'

# Ruby finite-state-machine-inspired API for modeling workflow 
gem 'workflow'
gem 'workflow-activerecord'

# This gem hooks up your Rails application with Roadie to help you generate HTML emails.
gem 'roadie-rails'

gem 'exception_notification'

# UDID
gem 'friendly_id'

# Cloud file storage service Amazon’s S3.
gem 'aws-sdk-s3', require: false

# SitemapGenerator is the easiest way to generate Sitemaps in Ruby. 
gem 'sitemap_generator'

# PgSearch builds named scopes that take advantage of PostgreSQL's full text search.
gem 'pg_search'

# Soft deletes for ActiveRecord done right.
gem 'discard'

# CSS styled emails without the hassle.
gem 'premailer-rails'

gem "scenic"

gem "mailgun-ruby"

gem "sortable-for-rails"

gem "matrix", "~> 0.4.2"
