Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.x.symkey = IO.readlines("config/keys/symkey.txt").map{|line| line.chomp("\n").split("=")}.select{|x| x[0]=="key"}[0][1]
  config.x.pem = File.read('config/keys/public.dev.pem')
  config.x.users = { 'Saarbrücken' => 'pw1', 'Bochum' => 'pw2' }
  config.x.festival_start = DateTime.parse("2018-06-20 06:00:00")
  config.x.festival_end = DateTime.parse("2018-07-10 18:00:00")
  config.x.deadline = DateTime.parse("2018-04-15 10:30:14")
  config.x.admin_email = 'festival_help@mail.de'
  
  #for timeliness gem (compare datetime-values delivered as strings)
  config.use_plugin_parser = true
  
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
end
