require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    #create contact_person
    @contact_persons_email = "maja.der.contact@mail.de"
    create_confirmed_contact_person(@contact_persons_email)
  end
  
  test "should get new" do
    #login contact_person
    post login_path, params: { contact_person: {hashed_email: @contact_persons_email } }
    #go to register page
    get root_path
    assert_response :success
  end
  
  test "send two emails after registration" do
    #login contact_person
    post login_path, params: { contact_person: {hashed_email: @contact_persons_email } }
    #load input hash from Factory
    input = attributes_for(:registration_input).merge(
      "start(2i)" => "6",
      "start(3i)" => "22",
      "start(4i)" => "12", 
      "end(2i)" => "7", 
      "end(3i)" => "5", 
      "end(4i)" => "16",
    )
    #assert email is queued after registration
    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      post registrations_path, params: { registration: input}
    end
    #assert that second last email sent was the confirm email sent to the right adress.
    confirm_email = ActionMailer::Base.deliveries[-2]
    assert_equal 'Confirm your registration for the festival', confirm_email.subject
    assert_equal input[:email].downcase, confirm_email.to[0]
    #assert that second last email was the email contact_person with the right subject.
    contact_person_email = ActionMailer::Base.deliveries[-1]
    assert_equal I18n.t("mail.registration_contact_person.subject", id: "1"), contact_person_email.subject
    assert_equal @contact_persons_email.downcase, contact_person_email.to[0].downcase
  end
  
  test "confirmation saves to database" do
    #setup: save an unconfirmed registration
    registration = build(:registration, :encrypted)
    registration.save(validate: false)
    assert_not_equal true, Registration.find_by(hashed_email: registration.hashed_email).confirmed
    #go to confirmation path of that registration
    get "#{registration_path(registration)}/confirm"
    assert_response :success
    #assert attribute confirmed of the record is true.
    assert_equal true, Registration.find_by(hashed_email: registration.hashed_email).confirmed
  end
end
