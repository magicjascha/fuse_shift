require 'test_helper'

class RegistrationMailerTest < ActionMailer::TestCase
  test "confirm" do
    create :registration
    @registration = build(:registration)
    email = RegistrationMailer.registration_confirm(@registration)
    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end
    #Test the body of the email
    assert_equal ["no-reply@festival-registration.de"], email.from
    assert_equal [@registration.email], email.to
    assert_equal 'Confirm your registration for the festival', email.subject
#     assert_select "a[href=?]", registration_confirm_url(@registration)
#     assert_select "a[href=?]", registration_url(@registration)
  end
end
