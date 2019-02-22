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

There is an additional confirmation process associated with the property "shift_confirmed" in the model of registration. The registered people should receive links after their shifts were calculated on a private computer outside this app. With these links they can either confirm or cancel their shift. The links are...
[URL]/registrations/[hashed_email]/shift_confirm_yes (confirm, saves 1 in shift_confirmed)
[URL]/registrations/[hashed_email]/shift_confirm_no (cancel, saves 0 in shift_confirmed)
... where [hashed_email] is the 256-bit SHA (SHA2 family) of the email-adress. In ruby it would be calculated with Digest::SHA2.hexdigest(email).


## Email-Confirmations
After the contact person/user submits a registration, the contact person, as well as the registered person obtain emails with the submitted data. The registered person needs to confirm their email-adress.

## Customization
Almost all text can be altered. This concerns the text of the info-box and headlines as well as all labels and helptexts of the input-fields.

- Make a file in config/locales/en_customize.yml 
  It will not be touched by updates (as opposed to en.yml)
- Search for the text you want to replace in config/locales/en.yml, look up the associated hierarchy of labels below the first level "en:" (which is replaced by "en_customize:" in this file).
- Reproduce the label-hierarchy here as given in the example below. This example would replace the headline of the new registrations page "Register" with "This is a new headline".
```
en_customize:
  views:
    new:
      headline: "This is a new headline"
```

## Configuration
You need to generate equivalents for all files in config/environments/keys/development in config/environments/keys/production, EXCEPT the private.pem. This is the private key, which should NOT be on the server in production.
 
* The public key for asymmetric encryption in public.pem
  Generate a private key "private.pem" on your private computer: 
  ```
  Generate openssl genrsa -des3 -out private.pem 2048
  ```
  Generate a public key based on that private key:
  ```
  openssl rsa -in private.pem -outform PEM -pubout -out public.pem
  ```
  Move the public key onto the server into the directory ```/congig/production```
  Keep the private key on your private computer to use it later for the download with [Fuse Shift Tools](https://github.com/magicjascha/fuse_shift_tools) 

  
* You need a 256-bit-key for the symmteric encryption in ```/config/production/symkey.txt```. E.g. you could generate it with:
  ```
  openssl enc -aes-256-cbc -k [secret] -P -md sha1
  ```
  where [secret] is some random word, for generating a random key. Don't mind the salt and initilization vector. Just put the key into the txt-file.

* The http-authentication-login for normal users http_auth_users.csv

  * The different logins are separated by line.
  * Username and password are separated by a comma.
  * Password needs to be hashed with bcrypt BCrypt::Password.create('password')
  * Only use UTF-8 valid characters.

* Proceed analogous with the http-authentication-login for the admin http_auth_admin.csv

* Specifics for the app: website title, deadline, festival start and end data