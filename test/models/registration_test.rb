require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase
  
  def setup
    #create contact_person and build registration
    @contact_person = create_confirmed_contact_person("emailofcontact@mail.de")
    @registration = build(:registration, :all_fields, contact_person: @contact_person)
  end
  
  test "factory is valid" do
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
    #create record
    build(:registration, :encrypted, contact_person: @contact_person).save(validate: false)
    #check if a registration with the same data is valid
    registration = build(:registration, contact_person: @contact_person)
    assert_not registration.valid?
  end 
  
end
