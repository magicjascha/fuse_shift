#todo:
#test form method and action
# put in methods
require 'test_helper'
require 'colorize'

class RegistrationProcessTest < ActionDispatch::IntegrationTest
  
  def setup
    #Login
    contact_persons_email = "contactmaja@mail.de"
    @contact_person = create_confirmed_contact_person(contact_persons_email)
    post login_path, params: { contact_person: {hashed_email: contact_persons_email } }    
    @registration = build(:registration, :all_fields, contact_person: @contact_person)#just need it for the path_helper
    @input = get_input_hash(@registration)#need it for using registrations_path_helper
  end
  
  test "valid registration saved to encrypted to database" do
    #go to registration page
    get root_path    
    #assert empty registration form
    assert_select 'form[action="/registrations"]'
    assert_select 'form[method="post"]'
    assert_select 'form input[type=hidden][name="_method"]', false
    assert_select "form input[type=text]", count: 7 #check for 7 empty text-input fields.
    assert_select "form input[type=text][value]", false
    #submit data to database, assert record was saved and confirm-email was queued    
    assert_difference 'Registration.count', 1 do
      assert_difference 'ActionMailer::Base.deliveries.size', +2 do
        post registrations_path, params: { registration: @input}
      end
    end
    assert_template 'localstorage_save'
    #compare saved record with encrypted input values
    saved_reg = Registration.find_by(hashed_email: @registration.hashed_email)
    assert_equal @input[:name], decrypt(saved_reg.name)
    assert_equal @input[:email].downcase, decrypt(saved_reg.email)
    assert_equal @input[:phonenumber], decrypt(saved_reg.phonenumber)
    assert_equal @input[:comment], decrypt(saved_reg.comment)
    assert_equal @input[:english], decrypt(saved_reg.english)
    assert_equal @input[:is_friend], decrypt(saved_reg.is_friend)
    assert_equal @input[:start], decrypt(saved_reg.start)
    assert_equal @input[:end], decrypt(saved_reg.end)
  end
  
  #fix test: change update-sucess page to edit view
  test "valid edit saves to database (localstorage autofills)" do
    edit_input = @input.merge({phonenumber: "0"*10, comment: "anotherComment"})
    #setup test record in database
    post registrations_path, params: { registration: @input}
    #go to edit-path of that registration
    get registration_path(@registration)
    #assert edit form
    assert_select %{form[action="#{registration_path(@registration)}"]}
    assert_select 'form input[type=hidden][name="_method"][value=?]', "put"
    assert_select "form input[type=text]", count: 6
    #submit new data
    put registration_path(@registration), params: { registration: edit_input}
    #assert update-success-page with data
    assert_equal registration_path(@registration), path
    assert_select "td", edit_input[:comment]
    #assert database record updated
    saved_reg = Registration.find_by(hashed_email: @registration.hashed_email)
    assert_equal @input[:name], decrypt(saved_reg.name)
    assert_equal @input[:email].downcase, decrypt(saved_reg.email)
    assert_equal edit_input[:phonenumber], decrypt(saved_reg.phonenumber)
    assert_equal edit_input[:comment], decrypt(saved_reg.comment)
    assert_equal @input[:english], decrypt(saved_reg.english)
    assert_equal @input[:is_friend], decrypt(saved_reg.is_friend)
    assert_equal @input[:start], decrypt(saved_reg.start)
    assert_equal @input[:end], decrypt(saved_reg.end)
  end
 
  #fix test: change update-sucess page to edit view
  test "valid edit with localstorage deleted saves to database" do
    edit_input = {phonenumber: "0"*10, comment: "anotherComment"}
    #setup test record in database
    post registrations_path, params: { registration: @input}
    #go to edit-path of that registration
    get registration_path(@registration)
    #submit new data
    put registration_path(@registration), params: { registration: edit_input}
    #assert update-success-page with data
    assert_equal registration_path(@registration), path
    assert_select "td", edit_input[:comment]
    #assert database record updated
    saved_reg = Registration.find_by(hashed_email: @registration.hashed_email)
    assert_equal @input[:name], decrypt(saved_reg.name)
    assert_equal @input[:email].downcase, decrypt(saved_reg.email)
    assert_equal edit_input[:phonenumber], decrypt(saved_reg.phonenumber)
    assert_equal edit_input[:comment], decrypt(saved_reg.comment)
    assert_equal @input[:english], decrypt(saved_reg.english)
    assert_equal @input[:is_friend], decrypt(saved_reg.is_friend)
    assert_equal @input[:start], decrypt(saved_reg.start)
    assert_equal @input[:end], decrypt(saved_reg.end)
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
  
  test "invalid edit (localstorage full)" do
    error_input = @input.merge({start: "2018-07-03 12:00", end: "2018-06-27 12:00", comment: "anotherComment"})
    #setup test record in database
    post registrations_path, params: { registration: @input}
    #go to edit-path of that registration
    get registration_path(@registration)
    #submit new data
    put registration_path(@registration), params: { registration: error_input}
    #assert filled edit form with errors 
    assert_equal registration_path(@registration), path
    assert_select 'form[action="'+registration_path(@registration)+'"]'
    assert_select 'form input[type=hidden][name="_method"][value=?]', "put"
    assert_select '#registration_start[value=?]', error_input[:start] #check if error-changed input field is filled with error_input
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
    assert_select  '#registration_name[value=?]', @input[:name]  #check if name input field is filled with old record
    assert_select '#registration_comment[value=?]', error_input[:comment] #check if changed non-error input field is new input

    #assert database-record unchanged 
    saved_reg = Registration.find_by(hashed_email: @registration.hashed_email)
    assert_equal @input[:name], decrypt(saved_reg.name)
    assert_equal @input[:email].downcase, decrypt(saved_reg.email)
    assert_equal @input[:phonenumber], decrypt(saved_reg.phonenumber)
    assert_equal @input[:comment], decrypt(saved_reg.comment)
    assert_equal @input[:start], decrypt(saved_reg.start)
    assert_equal @input[:end], decrypt(saved_reg.end)
  end
  
end
