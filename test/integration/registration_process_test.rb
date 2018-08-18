#todo:
#test form method and action
# put in methods
require 'test_helper'

class RegistrationProcessTest < ActionDispatch::IntegrationTest
  
  def setup
    #Login
    contact_persons_email = "contactmaja@mail.de"
    @contact_person = create_confirmed_contact_person(contact_persons_email)
    post login_path, params: { contact_person: {hashed_email: contact_persons_email } }
    
    @registration = build(:registration, :all_fields, contact_person: @contact_person)#just need it for the path_helper
    @input = get_input_hash(@registration)#need it for using registrations_path_helper
  end
  
#   test "valid registration and edit" do
#     #go to registration page
#     get root_path    
#     #assert empty registration form
#     assert_select 'form[action="/registrations"]'
#     assert_select 'form[method="post"]'
#     assert_select 'form input[type=hidden][name="_method"]', false
#     assert_select "form input[type=text]", count: 5 #check for 5 empty text-input fields.
#     assert_select "form input[type=text][value]", false
#     #submit data to database, assert record was saved and confirm-email was queued    
#     assert_difference 'Registration.count', 1 do
#       assert_difference 'ActionMailer::Base.deliveries.size', +2 do
#         post registrations_path, params: { registration: @input}
#       end
#     end
#     #assert success-create-page with data
#     assert_equal registrations_path, path
#     assert_select "td", @input[:name]
#     assert_select "td", @input[:email].downcase
#     assert_select "td", @input[:phonenumber]
#     #go to edit page
#     get registration_path(@registration)
#     #assert edit form
#     assert_equal registration_path(@registration), path
#     assert_select %{form[action="#{registration_path(@registration)}"]}
#     assert_select 'form input[type=hidden][name="_method"][value=?]', "put"
#     assert_select "form input[type=text]", count: 4
#     #submit data
#     put registration_path(@registration), params: { registration: {name: "Another One", phonenumber: ""}}
#     #assert update-success-page with data
#     assert_equal registration_path(@registration), path
#     assert_select "td", "Another One"
#     #assert database record updated
#     saved_reg = Registration.find_by(hashed_email: @registration.hashed_email)
#     assert_equal "Another One", decrypt(saved_reg.name)
#     assert_equal @input[:email].downcase, decrypt(saved_reg.email)
#     assert_equal @input[:phonenumber], decrypt(saved_reg.phonenumber)
#     assert_equal @input[:comment], decrypt(saved_reg.comment)
#     assert_equal @input[:english], decrypt(saved_reg.english)
#     assert_equal @input[:is_friend], decrypt(saved_reg.is_friend)
#   end
  
  test "encrypt registration right" do
    #setup test record in database
    assert_difference 'Registration.count', 1 do
      post registrations_path, params: { registration: @input}
    end
    #Load record from database
    saved_reg = Registration.last
    #assert data is not the raw input
    assert_not_equal(@input[:name], saved_reg.name)
    assert_not_equal(@input[:email].downcase, saved_reg.email)
    assert_not_equal(@input[:phonenumber], saved_reg.phonenumber)
    assert_not_equal(@input[:comment], saved_reg.comment)
    #assert data is decryptable
    assert_equal(@input[:name], decrypt(saved_reg.name))
    assert_equal(@input[:email].downcase, decrypt(saved_reg.email))
    assert_equal(@input[:phonenumber], decrypt(saved_reg.phonenumber))
    assert_equal(@input[:comment], decrypt(saved_reg.comment))
  end
  
  test "invalid registration" do
    input_with_invalid_email = @input.merge(email: "blabla")
    #go to registration page
    get root_path
    #submit data
    assert_no_difference 'Registration.count' do
      post registrations_path, params: { registration: input_with_invalid_email}
    end
    #assert filled registration-form with errors
    assert_equal "/registrations", path
    assert_select 'form[action="/registrations"]'
    assert_select 'form[method="post"]'
    assert_select 'form input[type=hidden][name="_method"]', false
    assert_select  '#registration_name[value=?]', input_with_invalid_email[:name]
    assert_select  '#registration_email[value=?]', input_with_invalid_email[:email]
    assert_select  '#registration_phonenumber[value=?]', input_with_invalid_email[:phonenumber]
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
    assert_select 'form[action="/registrations"]'
  end
  
#   test "invalid edit" do
#     error_input = {phonenumber: "0"*21, comment: "anotherComment"}
#     #setup test record in database
#     post registrations_path, params: { registration: @input}
#     #go to edit-path of that registration
#     get registration_path(@registration)
#     #assert edit form
#     assert_select %{form[action="#{registration_path(@registration)}"]}
#     assert_select 'form input[type=hidden][name="_method"][value=?]', "put"
#     assert_select "form input[type=text]", count: 4
#     #submit new data
#     put registration_path(@registration), params: { registration: error_input}
#     #assert filled edit form with errors 
#     assert_equal registration_path(@registration), path
#     assert_select %{form[action="#{registration_path(@registration)}"]}
#     assert_select 'form input[type=hidden][name="_method"][value=?]', "put"
#     assert_select  '#registration_name[value]', false  #check if non-changed name input field is empty
#     assert_select '#registration_phonenumber[value=?]', error_input[:phonenumber] #check if error-changed input field is filled right
#     assert_select '#registration_comment[value=?]', error_input[:comment] #check if changed non-error input field is filled right
#     assert_select "div#error_explanation"
#     assert_select "div.field_with_errors"
#     #assert database-record unchanged 
#     saved_reg = Registration.find_by(hashed_email: @registration.hashedEmail)
#     assert_equal @input[:name], decrypt(saved_reg.name)
#     assert_equal @input[:email].downcase, decrypt(saved_reg.email)
#     assert_equal @input[:phonenumber], decrypt(saved_reg.phonenumber)
#     assert_equal @input[:comment], decrypt(saved_reg.comment)
#   end
  
end
