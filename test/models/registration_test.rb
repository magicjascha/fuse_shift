require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase
  
  def setup
    @registration = Registration.new(
      name: "Example Name",
      email: "example@example.de",
      phonenumber: "1234",
      start: DateTime.new(2018, 6, 22, 12, 0),
      end: DateTime.new(2018, 7, 3, 8, 0)
    )
    @registration.hashed_email = digest(@registration.email)
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
  
  test "hashed_email should be unique" do
    build(:registration, :as_record).save(validate: false)
    registration = build(:registration, :with_hashed_email)
    assert_not registration.valid?
  end

  #for educational purposes
  test "hashed_email should be unique (second version)" do
    @registration.save!
    setup#assign a new record to @registration
    assert_not @registration.valid?
  end
  
end
