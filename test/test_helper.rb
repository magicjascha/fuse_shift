ENV['RAILS_ENV'] ||='test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
require 'hasher'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  include ApplicationHelper
  include RegistrationsHelper
  include Hasher
  include FactoryBot::Syntax::Methods
#   fixtures :all
  
  def decrypt(string)
    rsa_private_key = OpenSSL::PKey::RSA.new(File.read('config/keys/private.dev.pem'), "ruby")
    rsa_private_key.private_decrypt(Base64.strict_decode64(string))
  end

  # Add more helper methods to be used by all tests here...
end
