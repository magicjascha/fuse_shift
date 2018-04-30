require 'test_helper'

class RegistrationProcessTest < ActionDispatch::IntegrationTest
  
  def setup
    @registration = Registration.new(name: "Example Name", email: "eXample@Example.de", phonenumber: "1234")
    @registration.email.downcase!
    @registration.hashedEmail = digest(@registration.email)
  end
  
  test "valid registration and edit" do
    get root_path
    assert_template 'registrations/new'
    assert_select "form input[type=text]", count: 5 #check for 5 empty text-input fields.
    assert_select "form input[type=text][value]", false
    assert_difference 'Registration.count', 1 do
      post registrations_path, params: { registration: {name: @registration.name,
                                                        email: @registration.email, phonenumber: @registration.phonenumber}}
    end
    assert_template 'registrations/success'
    assert_equal registrations_path, path
    assert_select "td", @registration.name
    assert_select "td", @registration.email
    assert_select "td", @registration.phonenumber
    assert_select "a[href=?]", registration_path(@registration), text: "Edit"
    get registration_path(@registration)
    assert_template "edit"
    assert_select "form input[type=text]", count: 4 #check for 4 empty text-input fields.
    assert_select "form input[type=text][value]", false
    put registration_path(@registration), params: { registration: {name: "Another One", phonenumber: ""}}
    assert_template "registrations/update_success"
    assert_equal registration_path(@registration), path
    assert_select "td", "Another One"
  end
  
  test "encrypt registration right" do
    assert_difference 'Registration.count', 1 do
      post registrations_path, params: { registration: {name: @registration.name,
                                                        email: @registration.email, phonenumber: @registration.phonenumber}}
    end
    saved_reg = Registration.last
    assert_not_equal(@registration.name, saved_reg.name)
    assert_not_equal(@registration.email, saved_reg.email)
    assert_not_equal(@registration.phonenumber, saved_reg.phonenumber)
    rsa_private_key = OpenSSL::PKey::RSA.new(File.read('config/keys/private.dev.pem'), "ruby")
    decrypted_name = rsa_private_key.private_decrypt(Base64.strict_decode64(saved_reg.name))
    decrypted_email = rsa_private_key.private_decrypt(Base64.strict_decode64(saved_reg.email))
    decrypted_phonenumber = rsa_private_key.private_decrypt(Base64.strict_decode64(saved_reg.phonenumber))
    assert_equal(@registration.name, decrypted_name)
    assert_equal(@registration.email, decrypted_email)
    assert_equal(@registration.phonenumber, decrypted_phonenumber)
  end
  
  test "invalid registration" do
    get root_path
    assert_no_difference 'Registration.count' do
      post registrations_path, params: { registration: {name: @registration.name,
                                                        email: "blabla", phonenumber: @registration.phonenumber}}
    end
    assert_template 'registrations/new'
    assert_select  '#registration_name[value=?]', @registration.name
    assert_select  '#registration_email[value=?]', "blabla"
    assert_select  '#registration_phonenumber[value=?]', @registration.phonenumber
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
    assert_select 'form[action="/registrations"]'
    assert_equal "/registrations", path
  end
  
  test "invalid edit" do
    post registrations_path, params: { registration: {name: @registration.name,
                                                      email: @registration.email, phonenumber: @registration.phonenumber, city: "Salzburg"}}
    get registration_path(@registration)
    assert_template 'edit'
    assert_select "form input[type=text]", count: 4 #check for 4 empty text-input fields.
    assert_select "form input[type=text][value]", false
    put registration_path(@registration), params: { registration: {phonenumber: "0"*21, city: "Bochum"}}
    assert_template 'edit'
    assert_equal registration_path(@registration), path
    assert_select  '#registration_name[value]', false  #check if non-changed name input field is empty
    assert_select '#registration_phonenumber[value=?]', "0"*21 #check if error-changed input field is filled right
    assert_select '#registration_city[value=?]', "Bochum" #check if changed non-error input field is filled right
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
  end
  
  test "email-adress must be unique" do
    #fixtures don't act as if it's already in the database? -> have to add it first, can't do it in model-test, doesn't know post
    post registrations_path, params: { registration: {name: "bla",
                                                      email: @registration.email, phonenumber: "84839"}}
    assert_not @registration.valid?
    assert_not @registration.errors[:hashedEmail].empty?
  end
end
