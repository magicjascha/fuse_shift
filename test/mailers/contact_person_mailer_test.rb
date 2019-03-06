require 'test_helper'

class ContactPersonMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  test "confirm email" do
    #setup email and @contact_person
    contact_persons_email = "sandra@mail.de"
    @contact_person = build(:contact_person, :email_hashed, email: contact_persons_email)
    #check email from mailer
    email = ContactPersonMailer.confirm(@contact_person, contact_persons_email)
    #check email addresses and suject
    #assert_equal ["no-reply@festival-registration.de"], email.from
    assert_equal [Rails.configuration.x.send_mails_from], email.from
    assert_equal [contact_persons_email], email.to
    assert_equal I18n.t("mail.contact_person_confirm.subject"), email.subject
    #check email-body for confirm-link
    assert_match("#{root_url}contact_persons/#{@contact_person.hashed_email}/warning", email.html_part.body.decoded)
  end

end
