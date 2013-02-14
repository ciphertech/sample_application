require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module FavTabs
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
     config.active_record.observers = :photo_comment_observer #:cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    #Added by: Salil Gaikwad
    #Added on: 07/01/2012
    #Purpose:
    #++ This line is added for the autocomplete as per https://github.com/rails/jquery-ujs
    config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

#    @@config_settings = YAML.load_file("#{Rails.root.to_s}/config/credential_#{Rails.env}.yml")
#    config.action_mailer.delivery_method = :smtp
#    config.action_mailer.perform_deliveries = true
#    config.action_mailer.raise_delivery_errors = true
#    config.action_mailer.default_charset = "utf-8"
#    config.action_mailer.smtp_settings = {
#      :address        => @@config_settings["email_settings"]["address"],
#      :port           => @@config_settings["email_settings"]["port"],
#      :domain         => @@config_settings["email_settings"]["domain"],
#      :authentication => @@config_settings["email_settings"]["authentication"],
#      :user_name      => @@config_settings["email_settings"]["user_name"],
#      :password       => @@config_settings["email_settings"]["password"]
#    }

  end
end
