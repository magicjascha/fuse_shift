#todo:
#test form method and action
# put in methods
require 'test_helper'

class RegistrationProcessTest < ActionDispatch::IntegrationTest
  
  def setup
    @username = "Bochum"
    @input = {
      name: "Example Name",
      email: "eXample@Example.de",
      phonenumber: "1234",
      city: "Salzburg",
      "start(2i)" => "6",
      "start(3i)" => "22",
      "start(4i)" => "12", 
      "end(2i)" => "7", 
      "end(3i)" => "5", 
      "end(4i)" => "16",
    }
#     @registration = Registration.new({hashed_email: digest(@input[:email].downcase)})
#     request.headers['Authorization'] = ActionController::HttpAuthentication::Digest.
#     encode_credentials('get', @username, USERS[@username],)
  end
  
  test "valid registration and edit" do
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
      assert_difference 'ActionMailer::Base.deliveries.size', +1 do
        post registrations_path, params: { registration: @input}
      end
    end
    #assert success-create-page with data
    assert_equal registrations_path, path
    assert_select "td", @input[:name]
    assert_select "td", @input[:email].downcase
    assert_select "td", @input[:phonenumber]
    assert_select "td", @username
    #go to edit page
    get registration_path(@registration)
    #assert empty edit form
    assert_equal registration_path(@registration), path
    assert_select %{form[action="#{registration_path(@registration)}"]}
    assert_select 'form input[type=hidden][name="_method"][value=?]', "put"
    assert_select "form input[type=text]", count: 6
    assert_select "form input[type=text][value]", false
    #submit data
    put registration_path(@registration), params: { registration: {name: "Another One", phonenumber: ""}}
    #assert update-success-page with data
    assert_equal registration_path(@registration), path
    assert_select "td", "Another One"
    #assert database record updated
    saved_reg = Registration.find_by(hashed_email: @registration.hashed_email)
    assert_equal "Another One", decrypt(saved_reg.name)
    assert_equal @input[:email].downcase, decrypt(saved_reg.email)
    assert_equal @input[:phonenumber], decrypt(saved_reg.phonenumber)
    assert_equal @username, decrypt(saved_reg.city)
  end
  
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
    assert_not_equal(@input[:city], saved_reg.city)
    #assert data is decryptable
    assert_equal(@input[:name], decrypt(saved_reg.name))
    assert_equal(@input[:email].downcase, decrypt(saved_reg.email))
    assert_equal(@input[:phonenumber], decrypt(saved_reg.phonenumber))
    assert_equal(@input[:city], decrypt(saved_reg.city))
  end
  
  test "invalid registration" do
    error_input = @input.merge(email: "blabla")
    #go to registration page
    get root_path
    #submit data
    assert_no_difference 'Registration.count' do
      post registrations_path, params: { registration: error_input}
    end
    #assert filled registration-form with errors
    assert_equal "/registrations", path
    assert_select 'form[action="/registrations"]'
    assert_select 'form[method="post"]'
    assert_select 'form input[type=hidden][name="_method"]', false
    assert_select  '#registration_name[value=?]', error_input[:name]
    assert_select  '#registration_email[value=?]', error_input[:email]
    assert_select  '#registration_phonenumber[value=?]', error_input[:phonenumber]
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
    assert_select 'form[action="/registrations"]'
  end
  
  test "invalid edit" do
    error_input = {phonenumber: "0"*21, city: "Bochum"}
    #setup test record in database
    post registrations_path, params: { registration: @input}
    #go to edit-path of that registration
    get registration_path(@registration)
    #assert empty edit form
    assert_select %{form[action="#{registration_path(@registration)}"]}
    assert_select 'form input[type=hidden][name="_method"][value=?]', "put"
    assert_select "form input[type=text]", count: 6
    assert_select "form input[type=text][value]", false
    #submit new data
    put registration_path(@registration), params: { registration: error_input}
    #assert filled edit form with errors 
    assert_equal registration_path(@registration), path
    assert_select %{form[action="#{registration_path(@registration)}"]}
    assert_select 'form input[type=hidden][name="_method"][value=?]', "put"
    assert_select  '#registration_name[value]', false  #check if non-changed name input field is empty
    assert_select '#registration_phonenumber[value=?]', error_input[:phonenumber] #check if error-changed input field is filled right
    assert_select '#registration_city[value=?]', error_input[:city] #check if changed non-error input field is filled right
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
    #assert database-record unchanged 
    saved_reg = Registration.find_by(hashed_email: @registration.hashedEmail)
    assert_equal @input[:name], decrypt(saved_reg.name)
    assert_equal @input[:email].downcase, decrypt(saved_reg.email)
    assert_equal @input[:phonenumber], decrypt(saved_reg.phonenumber)
    assert_equal @input[:city], decrypt(saved_reg.city)
  end
  
end
