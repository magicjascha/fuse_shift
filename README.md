# FuseShift

This app was constructed for data-collection with high security needs. 

## Encryption
The data submitted by the users is saved assymmetrically encrypted on the server. Since only the public key resides on the computer, it can only be decrypted after downloading it to a private computer, where the private key resides.

To enable the users to look at submitted data nevertheless, a symmetrically encrypted copy of the data is saved in the browser's localstorage. It can only be decrypted when the browser communicated with the app.

## Who submits what?

There are users "contact people" which can submit several people's data-sets "registrations". They need to login in order to do so. This happens in two steps: 
1. with an http-authentication-login
2. simply typing in their email-adress without any further password-authentication. The email-adress needs to be confirmed at the first login.

-> The http-authentication-logins need to be given to the users through other secure ways. It is assumed that several people with the same http-authentication-login don't have an interest to manipulate the other users data.

As the app collects data for putting up a shift plan,the datafields for each registration are: Name, Shortname, Email, Cellphone Number, Is it a Friend?, Languages, Arrival, Departure, Comment, Contact Person's Email, Contact Person's City.
- Name, Email, Arrival, Departure are mandatory
- Contact person's city is filled automatically by the http-authentication-username
- Contact Person's email is filled automatically by the the user's login

## Email-Confirmations
After the contact person/user submits a registration, the contact person, as well as the registered person obtain emails with the submitted data. The registered person needs to confirm their email-adress.

## Customization
Almost all text can be altered by making changes in config/locale.en
This concerns the text of the info-box as well as all labels and helptexts of the input-fields.

## Configuration
in config/environments/production.rb in the first lines:
 
* The public key for the asymmteric encryption must be placed under following path 'config/keys/public.dev.pem' or the path in the variable config.x.pem customized
  ```ruby
  config.x.pem = File.read('config/keys/public.dev.pem')```ruby

* The key for the symmteric encryption must be placed under following path 'config/keys/symkey.txt' or the path in the variable onfig.x.symkey customized
  ```ruby
  config.x.symkey = IO.readlines("config/keys/symkey.txt").map{|line| line.chomp("\n").split("=")}.select{|x| x[0]=="key"}[0][1]```ruby

* The http-authentication-login must be ........[change]
* There must be entered a start date and end date for the schedule and a registration deadline.
  ```ruby
  config.x.festival_start = DateTime.parse("2018-06-20 06:00:00")
  config.x.festival_end = DateTime.parse("2018-07-10 18:00:00")
  config.x.deadline = DateTime.parse("2018-04-15 10:30:14")```ruby

* The admin should leave an email, the users can turn to for errors
  ```ruby
  config.x.admin_email = 'festival_help@mail.de'```ruby