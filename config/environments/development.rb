require 'csv'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  
  #ausserhalb definieren, damit das in den views ist?
  config.x.pem = File.read('config/keys/public.dev.pem')
  config.x.symkey = IO.readlines("config/keys/symkey.txt").map{|line| line.chomp("\n").split("=")}.select{|x| x[0]=="key"}[0][1]
  csv_text = File.read('config/keys/http_auth.csv')
  csv = CSV.parse(csv_text, :headers => false).to_h
#   p csv.to_h  
#   csv.each do |row|
#     p row
#     row
#   end
  config.x.users = csv
#   config.x.users = { 'Saarbrücken' => 'pw1', 'Bochum' => 'pw2' }
  config.x.festival_start = DateTime.parse("2018-06-20 06:00:00")
  config.x.festival_end = DateTime.parse("2018-07-10 18:00:00")
  config.x.deadline = DateTime.parse("2018-04-15 10:30:14")
  config.x.admin_email = 'festival_help@mail.de'
  
  #for timeliness gem (compare datetime-values delivered as strings)
  config.use_plugin_parser = true

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false
  
  # added for letter opener https://github.com/ryanb/letter_opener
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  
  #enabling urls in mailers
  config.action_mailer.default_url_options = { host: "localhost:3000" }

#   config.action_mailer.smtp_settings = {
#     address:              'smtp.gmail.com',
#     port:                 587,
#     domain:               'gmail.com',
#     user_name:            ENV["EMAIL_USER_NAME"],
#     password:             ENV["EMAIL_PASSWORD"],
#     authentication:       :plain,
#     enable_starttls_auto: true
#   }
#   
#   
  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
