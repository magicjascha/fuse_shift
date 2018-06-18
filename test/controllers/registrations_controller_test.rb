require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  
  test "should get new" do
    get root_path
    assert_response :success
  end
  
  test "send confirm-email" do
    #load input hash from Factory
    input = attributes_for(:registration).merge(
      "start(2i)" => "6",
      "start(3i)" => "22",
      "start(4i)" => "12", 
      "end(2i)" => "7", 
      "end(3i)" => "5", 
      "end(4i)" => "16",
    )
    #assert email is queued after registration
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post registrations_path, params: { registration: input}
    end
    #assert that it's the right email
    confirm_email = ActionMailer::Base.deliveries.last
    assert_equal 'Confirm your registration for the festival', confirm_email.subject
    assert_equal input[:email].downcase, confirm_email.to[0]
  end
  
  test "confirmation saves to database" do
    #build a registration and save
    registration = build(:registration, :as_record)
    registration.save(validate: false)
    assert_equal nil, Registration.find_by(hashed_email: registration.hashed_email).confirmed
    #go to confirmation path for that registration
    get "#{registration_path(registration)}/confirm"
    assert_response :success
    #assert attribute confirmed of the record is true.
    assert_equal true, Registration.find_by(hashed_email: registration.hashed_email).confirmed
  end
end
