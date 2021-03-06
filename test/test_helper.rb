ENV['RAILS_ENV'] ||='test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
require 'hasher'
require 'minitest/rails/capybara'
require 'colorize'
Minitest::Reporters.use!

# class ActionDispatch::IntegrationTest
#   # Make the Capybara DSL available in all integration tests
#   include Capybara::DSL
#   # Make `assert_*` methods behave like Minitest assertions
#   include Capybara::Minitest::Assertions
# 
#   # Reset sessions and driver between tests
#   # Use super wherever this method is redefined in your individual test classes
#   def teardown
#     Capybara.reset_sessions!
#     Capybara.use_default_driver
#   end
# end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  include ApplicationHelper
  include RegistrationsHelper
  include Hasher
  include FactoryBot::Syntax::Methods
#   fixtures :all
  
  def decrypt(string)
    rsa_private_key = OpenSSL::PKey::RSA.new(File.read('config/keys/development/private.pem'), "ruby")
    rsa_private_key.private_decrypt(Base64.strict_decode64(string))
  end
  
  def select_date_and_time(datetime, options = {})
    field = options[:from]
    base_id = find(:xpath, ".//label[contains(.,'#{field}')]")[:for]
    day, month, hour = datetime.split(',')
    select month,  :from => "#{base_id}_2i" #month
    select day, :from => "#{base_id}_3i" #day 
    select hour,  :from => "#{base_id}_4i" #hour
  end  

  def create_confirmed_contact_person(email)#returns record with clear-text-email
    record = build(:contact_person, :confirmed, :email_hashed, email: email)
    record.save(validate: false)
    record[:hashed_email] = email
    record
  end
  
  def get_input_hash(registration)
    data = registration.attributes.symbolize_keys().select{|key,value| ![:hashed_email, :contact_person_id, :confirmed, :shift_confirmed, :created_at, :updated_at].include?(key)}
    data
  end
  
  def get_displayed_data(registration)
    data = registration.attributes.symbolize_keys().select{|key,value| ![:hashed_email, :contact_person_id, :confirmed, :shift_confirmed, :created_at, :updated_at, :id].include?(key)}
    data[:hashid] = digest(registration.email)
    data
  end
end
