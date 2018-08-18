require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase
  
  def setup
    #create contact_person with factory
    contact_persons_email = build(:contact_person).hashed_email
    @contact_person = build(:contact_person, :confirmed, :as_record)
    @contact_person.save(validate: false)
    @registration = Registration.new(
    name: "Example Name",
    email: "example@example.de",
    phonenumber: "1234",
    start: DateTime.new(2018, 6, 22, 12, 0),
    end: DateTime.new(2018, 7, 3, 8, 0),
    contact_persons_email: contact_persons_email,
    contact_person: @contact_person
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
    #create registration with factory
    build(:registration, :as_record, contact_person: @contact_person).save(validate: false)
    registration = build(:registration, :with_hashed_email)
    assert_not registration.valid?
  end 
  
end
