ENV['RAILS_ENV'] ||='test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
require 'hasher'
require 'digest/md5'
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
  
  def authenticate_with_http_digest(user, password, &request_trigger)
    request.env['HTTP_AUTHORIZATION'] = encode_credentials(user, password, &request_trigger)
    request_trigger.call
  end
  
  # Shamelessly stolen from the Rails 4 test framework.
  # See https://github.com/rails/rails/blob/a3b1105ada3da64acfa3843b164b14b734456a50/actionpack/test/controller/http_digest_authentication_test.rb
  def encode_credentials(user, password, &request_trigger)
    # Perform unauthenticated request to retrieve digest parameters to use on subsequent request
    request_trigger.call
    expect(response).to have_http_status(:unauthorized)
    
    credentials = decode_credentials(response.headers['WWW-Authenticate'])
    credentials.merge!({ username: user, nc: "00000001", cnonce: "0a4f113b", password_is_ha1: false })
    path_info = request.env['PATH_INFO'].to_s
    credentials.merge!(uri: path_info)
    request.env["ORIGINAL_FULLPATH"] = path_info
    ActionController::HttpAuthentication::Digest.encode_credentials(request.method, credentials, password, credentials[:password_is_ha1])
  end
  
  # Also shamelessly stolen from the Rails 4 test framework.
  # See https://github.com/rails/rails/blob/a3b1105ada3da64acfa3843b164b14b734456a50/actionpack/test/controller/http_digest_authentication_test.rb
  def decode_credentials(header)
    ActionController::HttpAuthentication::Digest.decode_credentials(header)
  end
  
#   def authenticate_with_http_digest(user = API_USERNAME, password = API_PASSWORD, realm = API_REALM)
#     ActionController::Base.class_eval { include ActionController::Testing }
#     
#     @controller.instance_eval %Q(
#     alias real_process_with_new_base_test process_with_new_base_test
#     def process_with_new_base_test(request, response)
#       credentials = {
#         :uri => request.url,
#         :realm => "#{realm}",
#         :username => "#{user}",
#         :nonce => ActionController::HttpAuthentication::Digest.nonce(request.env['action_dispatch.secret_token']),
#         :opaque => ActionController::HttpAuthentication::Digest.opaque(request.env['action_dispatch.secret_token'])
#     }
#     request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Digest.encode_credentials(request.request_method, credentials, "#{password}", false)
#     real_process_with_new_base_test(request, response)
#     end
#     )
#   end
  
end
