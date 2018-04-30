require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase
  
  def setup
    @registration = Registration.new(name: "Example Name", email: "example@example.de", phonenumber: "1234")
    @registration.hashedEmail = digest(@registration.email)
  end
  
  test "should be valid" do
    assert @registration.valid?
  end
  
  test "name should be present" do
    @registration.name = ""
    assert_not @registration.valid?
  end
  
  test "email should be present and valid" do
    invalid_emails = ["@bla.de", "bla@de", "bla.de", "bla@bla", "blö@blö.de", ""]
    for @registration.email in invalid_emails
      assert_not @registration.valid? 
    end
  end
  
end
