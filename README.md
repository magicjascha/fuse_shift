# README

Still Missing:

1. Registration App:

IN REGISTRATIONS:
* hashed-email: correct ugly small mistakes in the validation-message for emails, originating from validating the email with attribute hashed-email not the email itself: 
  * email-field should be red, when invalid
  * "email has already been taken" instead of "Hashedemail has already been taken".
* Success-view improvements:
  * Instead of hitting the backwards button to correct the email-address, the input-data should be handed over to a complete new registration, cause otherwise there might be confusing outdated error-messages about the input.
  * link to the update view and hand over data
* edit-view: 
  * take handed over email (is at the moment a stub in the edit-action)
  * make encrypted data invisible/delete @registration?
  * check where update will post to (at the moment there is a hack for registration_path in the registrations-helper)
* update-action and view
* attributes shifts and languages
* some validations
* tests

OTHER TASKS
* sending out confirmation-emails and make a confirmation-view.
* help-text for the input fields
ONLY ADMIN-ACCESS
* input shifts
* upload public key
* download data

* One user has to be able to make several registrations

LATER:
* adjusting labels and helptext for the input-fields


2. Evalutation App
....

DONE:
* registration
* encrpytion
* hashed email for id
* edit-view




Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
