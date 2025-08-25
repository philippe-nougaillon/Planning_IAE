require_relative "boot"

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Planning
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.i18n.default_locale = :fr

    # RackCors conf 
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get]
      end
    end

    config.active_job.queue_adapter = :sucker_punch

    # pour fixer Psych::DisallowedClass in Devise::SessionsController#create (Tried to load unspecified class: ActiveSupport::TimeWithZone):
    config.active_record.use_yaml_unsafe_load = true

    # Solid queue : pour utiliser à sa manière le contrôle d'accès
    config.mission_control.jobs.http_basic_auth_enabled = false
    config.mission_control.jobs.base_controller_class = "MissionControlAdminController"
  end
end
