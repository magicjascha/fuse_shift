require 'test_helper'

class RegistrationHelperTest < ActionView::TestCase
  
  test "registrations path helper" do
    assert_equal "/registrations", registrations_path
  end
  
  test "registration path helper with id hashed_email" do
    email = "bla@bla.de"
    @registration = build(:registration, email: email)
    assert_equal "/registrations/#{digest(email)}", registration_path(@registration)
  end
  
end