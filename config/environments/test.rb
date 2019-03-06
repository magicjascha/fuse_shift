Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.x.pem = File.read('config/keys/development/public.pem')
  config.x.symkey = File.read("config/keys/development/symkey.txt")
  
  #config.x.auth_users contains users {{'Saarbruecken', 'pw1'},{'Bochum', 'pw2'}, {'Ulm', 'pw3'}}
  csv_text_http_auth_users = File.read('config/keys/development/http_auth_users.csv')
  config.x.auth_users = CSV.parse(csv_text_http_auth_users, :headers => false).to_h
  
  csv_text_http_auth_admin = File.read('config/keys/development/http_auth_admin.csv')
  config.x.auth_admin = CSV.parse(csv_text_http_auth_admin, :headers => false).to_h
 
  csv_text_config_data = File.read('config/keys/development/config_data.csv')
  config_data_hash = CSV.parse(csv_text_config_data, :headers => false).to_h
  config.x.website_title = config_data_hash["Website Title"]
  config.x.festival_start = DateTime.parse(config_data_hash["Festival Start"])
  config.x.festival_end = DateTime.parse(config_data_hash["Festival End"])
  config.x.deadline = DateTime.parse(config_data_hash["Deadline"])
  config.x.admin_email = config_data_hash["Admin Email"]
  config.x.send_mails_from = "festival@mail.de"
  
  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.seconds.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr
  
  #enabling urls in mailers (doesn't work)
#   config.action_mailer.default_url_options = { host: "localhost:3000" }
  
  #setting root_url genreally (doesn't work)
#   config.action_controller.default_url_options = { host: "localhost:3000" } 
  Rails.application.routes.default_url_options[:host] = 'localhost:3000'

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true
end
