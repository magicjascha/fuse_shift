# FuseShift

This app was constructed for data-collection with high security needs. 

## Encryption
The data submitted by the users is saved assymmetrically encrypted on the server. Since only the public key resides on the server, it can only be decrypted after downloading it to a private computer, where the private key resides.

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
You need to generate equivalents for all files in config/environments/keys/development in config/environments/keys/production, EXCEPT the private.pem. This is the private key, which should NOT be on the server in production.
 
* The public key for assymetric encryption public.pem

* The key for the symmetric encryption symkey.txt

* The http-authentication-login for normal users http_auth_users.csv

  * The different logins are separated by line.
  * Username and password are separated by a comma.
  * Password needs to be hashed with bcrypt BCrypt::Password.create('password')
  * Only use UTF-8 valid characters.

* Proceed analogous with the http-authentication-login for the admin http_auth_admin.csv

* Specifics for the app: website title, deadline, festival start and end data