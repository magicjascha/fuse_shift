require 'test_helper'

class ContactPersonsControllerTest < ActionDispatch::IntegrationTest
  
  test "should get new" do
    get contact_persons_new_url
    assert_response :success
  end
  
  test "confirm saves to database" do
    #build and save record with confirmed: nil
    @contact_person = build(:contact_person, :as_record)
    @contact_person.save(validate: false)
    #not confirmed in database before hitting confirm-link
    assert_not_equal true, ContactPerson.find_by(hashed_email: @contact_person.hashed_email).confirmed
    #go to confirmation link
    get contact_person_confirm_path(@contact_person)
    assert_redirected_to root_path
    #confirmed in database
    assert_equal true, ContactPerson.find_by(hashed_email: @contact_person.hashed_email).confirmed 
  end
  
  test "login and logout works" do
    #build a confirmed record
    build(:contact_person, :as_record, :confirmed).save(validate: false)
    #get unhashed email from factory
    contact_persons_email = build(:contact_person).hashed_email
    #login
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post login_path, params: { contact_person: {hashed_email: contact_persons_email } }
    end
    assert_redirected_to root_path
    follow_redirect!
    assert_equal root_path, path
    #logout
    get logout_path
    #check that registration page request is redirected
    get root_path
    assert_redirected_to login_path
    follow_redirect!
    assert_equal login_path, path
  end
  
  test "unknown email-adress login sends confirm-email" do
    #check if email was sent
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post login_path, params: { contact_person: {hashed_email: "unknown@email.de" } }
    end
    #check last sent email has the right subject and address
    last_email = ActionMailer::Base.deliveries.last
    assert_equal I18n.t("mail.contact_person_confirm.subject"), last_email.subject
    assert_equal "unknown@email.de", last_email.to[0]
    #check the response
    assert_response :success
    assert_equal login_path, path
  end
  
  test "unconfirmed email-adress login sends confirm-email" do
    #build and save record with confirmed: nil
    build(:contact_person, :as_record).save(validate: false)
    #get unhashed email from factory
    unhashed_email = build(:contact_person).hashed_email
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post login_path, params: { contact_person: {hashed_email: unhashed_email } }
    end
    last_email = ActionMailer::Base.deliveries.last
    assert_equal I18n.t("mail.contact_person_confirm.subject"), last_email.subject
    assert_equal unhashed_email, last_email.to[0]
    #check the response
    assert_response :success
    assert_equal login_path, path
  end
  
end
