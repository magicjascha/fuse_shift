require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  
  test "should get new" do
    get root_path
    assert_response :success
  end
  
  test "send confirm-email" do
    #load input hash from Factory
    input = attributes_for(:registration)
    #... and corresponding registration 
    registration = build(:registration, :with_hashed_email)
    #assert email is queued after registration
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post registrations_path, params: { registration: input}
    end
    #assert email_content
    confirm_email = ActionMailer::Base.deliveries.last
    assert_equal 'Confirm your registration for the festival', confirm_email.subject
    assert_equal input[:email].downcase, confirm_email.to[0]
    assert_match(registration_path(registration), confirm_email.html_part.body.decoded)
#     assert_match(registration_url(registration), confirm_email.html_part.body.decoded)-> fix default_url_options in test.rb
#     assert_match(registration_confirm_url(registration), confirm_email.html_part.body.decoded)
#     assert_equal("http://localhost:3000/", root_url)
  end
  
  test "confirmation saves to database" do
    #build a registration and save
    registration = build(:registration, :as_record)
    registration.save(validate: false)
    assert_equal nil, Registration.find_by(hashedEmail: registration.hashedEmail).confirmed
    #go to confirmation path for that registration
    get "#{registration_path(registration)}/confirm"
    assert_response :success
    #assert attribute confirmed of the record is true.
    assert_equal true, Registration.find_by(hashedEmail: registration.hashedEmail).confirmed
  end
end
