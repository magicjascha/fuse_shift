require 'test_helper'

class RegistrationMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers
  
  test "confirm-email after registration" do
    #get data into @registration
    @registration = build(:registration)
    @data = get_data(@registration)
    email = RegistrationMailer.registration_confirm(@registration, @data)
    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end
    #Test the email content
    assert_equal ["no-reply@festival-registration.de"], email.from
    assert_equal [@registration.email], email.to
    assert_equal 'Confirm your registration for the festival', email.subject
    assert_match(registration_confirm_url(@registration), email.html_part.body.decoded)
    #Test for values and key labels (from locale)
    for i in 0..(@data.length-1) do
      assert_match("<th>#{I18n.t("activerecord.attributes.registration.#{@data.keys[i]}")}</th>".gsub("'","&#39;"), email.html_part.body.decoded)
      if @data.values[i]
        if @data.values[i].respond_to?(:strftime)
          assert_match("<td>#{I18n.l(@data.values[i], format: :short_datetime)}</td>", email.html_part.body.decoded)
        else
          assert_match("<td>#{@data.values[i]}</td>", email.html_part.body.decoded)
        end
      end      
    end
  end
  
  test "registration-email to contact_person" do
    #get data into @registration
    @registration = build(:registration)
    @registration.save(validate:false)
    @data = get_data(@registration)
    email = RegistrationMailer.registration_contact_person(@registration, @data)
    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end
    #Test the email content
    assert_equal ["no-reply@festival-registration.de"], email.from
    assert_equal [@registration.contact_persons_email], email.to
    assert_equal "You registered somone with ID #{@registration.id} for the festival", email.subject
    assert_match(registration_url(@registration), email.html_part.body.decoded)
    #Test for values and key labels (from locale) in a table
    for i in 0..(@data.length-1) do
      assert_match("<th>#{I18n.t("activerecord.attributes.registration.#{@data.keys[i]}")}</th>".gsub("'","&#39;"), email.html_part.body.decoded)
      if @data.values[i]
        #for dates there should be the custom format from the locale
        if @data.values[i].respond_to?(:strftime)
          assert_match("<td>#{I18n.l(@data.values[i], format: :short_datetime)}</td>", email.html_part.body.decoded)
        else
          assert_match("<td>#{@data.values[i]}</td>", email.html_part.body.decoded)
        end
      end      
    end
  end  
end
