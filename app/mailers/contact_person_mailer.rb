class ContactPersonMailer < ApplicationMailer
  default from: Rails.configuration.x.send_mails_from

  def confirm(contact_person, contact_persons_email)
    @contact_person = contact_person
    mail(to: contact_persons_email, subject: I18n.t("mail.contact_person_confirm.subject"))
  end
end
