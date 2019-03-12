# FuseShift

This app was constructed for data-collection with high security needs.

## Table of Contents
* [Functionality](#functionality)
  * [Encryption](#encryption)
  * [Who submits what?](#who-submits-what)
  * [Email-Confirmations](#email-confirmations)
    * [Shift_confirmed: an additional confirmation process](#shift_confirmed-an-additional-confirmation-process)
  * [Browser-Memory](#browser-memory)
  * [Download Data](#download-data)
* [Customization](#customization)
* [Configuration](#configuration)

## Functionality

### Encryption
The data submitted by the users is saved assymmetrically encrypted on the server. Since only the public key resides on the server, it can only be decrypted after downloading it to a private computer, where the private key resides.

To enable the users to look at submitted data nevertheless, a symmetrically encrypted copy of the data is saved in the browser's localstorage. It can only be decrypted when the browser communicates with the app.

### Who submits what?

There are users "contact people" which can submit several people's data-sets "registrations". They need to login in order to do so. This happens in two steps:
1. with an http-authentication-login
2. simply typing in their email-adress without any further password-authentication. The email-adress needs to be confirmed at the first login.

-> The http-authentication-logins need to be given to the users through other secure ways. It is assumed that several people with the same http-authentication-login don't have an interest to manipulate each others data. They will not stumble into the registrations of other contact-people by accident, but if someone knows the email-address of a contact-person with the same http-authentication-login they can also log-in as that contact-person.

As the app collects data for putting up a shift plan, the data-fields for each registration are: 
```
Name(string)
Shortname(string)
Email (string, working email-address)
Cellphone Number(string)
Is it a Friend?(boolean)
English(boolean)
German(boolean)
French (boolean)
Arrival (string parsable as Datetime)
Departure(string, parsable as Datetime)
Comment(string)
Contact Person's Email (string, working email-address)
Contact Person's City (string, =username of http-authentication).
```
(Internally all of those database-columns of the model Registration are strings to enable encryption)

<b>Internal functions of fields:</b>
- Name, Shortname, Email, Arrival, Departure are mandatory
- Arrival and Departure are strings that are parsable as datetime-objects.
- To Email and Contact-persons email will be send confirmation emails.
- The shortname is used within the app for easier identification by the contact-person
- Contact person's city is filled automatically by the http-authentication-username
- Contact Person's email is filled automatically by the the user's login

While you can not change those app-internal functions, you can change ther labels and helptexts displayed to the users. [Customize](#customization) the locale for that.

After registration the contactperson finds a table of their registrations in the sidebar, which they can choose to edit/update or delete. Every information except the email-address can be updated, as the hash of the email-address is used as ID.

### Email-Confirmations
After the contact person/user submits a registration, the contact person, as well as the registered person obtain emails with the submitted data. 

The registered person needs to confirm their email-adress. The contact-person can see in the sidebar table who confirmed their email-address.

All email-texts can be [customized](#customization).

#### Shift_confirmed: an additional confirmation process
You can use an additional confirmation process associated with the attribute "shift_confirmed" of each registration record. After you assigned shifts, you probably want to send those to the people and have them confirm the shift. With these links, which you can put in that email, they can either confirm or cancel their shift:
```
[URL]/registrations/[hashed_email]/shift_confirm_yes (confirm, saves 1 in shift_confirmed)
[URL]/registrations/[hashed_email]/shift_confirm_no (cancel, saves 0 in shift_confirmed)
```
... where [hashed_email] is the 256-bit SHA (SHA2 family) of the email-adress. If you have ruby installed somewhere, you can calculate it like this:

In the terminal put   ```irb  ``` for opening the ruby console and then
```
require 'digest'
Digest::SHA2.hexdigest('mail@mail.net').
```
### Browser-Memory

As the data in the database is asymmetrically encrypted and cannot be decrypted on the server, there are symmetrically encrypted versions for each registration in the browser's localstorage which are fetched via javascript for decryption everytime the contact-person refreshes their page.

This process presupposes that the contact-person uses always the same browser. To detect this a timestamp of the last update-process has to match between the browser's localstorage record (if existent) and the database record. If a user wants to edit an individual record and this match fails for it, they are warned. If they update nevertheless, the failed record is deleted from the browser's localstorage. However, the contact-person can still see an anonymous record in the sidebar's registration table, the record still exists with all validity in the database and can still be updated.

After the record was deleted from the browser-memory the contact-person can still identify and update the records by looking into the emails with the submitted data they received: They can click the edit link or compare IDs with the registrations in the app. <b>However if the contact-person deletes the confirmation emails and the browser-data, they will not be able to identify which record is which and therefore lose their ability to update.</b>

After a browser-switch/localstorage-delete the new inputs are again accumulated in the browser-memory.

### Download data

When you go to [URL]/registrations, behind the http-authentication for admins, you find the data json-formatted ready for download.There are 4 subset-datasets with queries available:

```
[URL]/registrations?confirmed=true
[URL]/registrations?confirmed=false
[URL]/registrations?shift_confirmed=true
[URL]/registrations?shift_confirmed=false
```

You can use [Fuse Shift Tools](https://github.com/magicjascha/fuse_shift_tools) to download and decrypt the registrations to obtain a csv-file.


## Customization
Almost all text can be altered. This concerns the text of the info-box and headlines as well as all labels and helptexts of the input-fields.

- Make a file in ```config/locales/en_customize.yml```
  It will not be touched by updates (as opposed to ```en.yml```)
- Search for the text you want to replace in ```config/locales/en.yml```, look up the associated hierarchy of labels below the first level "en:" (which is replaced by "en_customize:" in this file).
- Reproduce the label-hierarchy here as given in the example below. This example would replace the headline of the new registrations page "Register" with "This is a new headline".
```
en_customize:
  views:
    new:
      headline: "This is a new headline"
```
- If you use an ephemeral file system like Heroku, that deletes every file not tracked by git, you can instead copy the content of ```config/locales/en_customize.yml``` into an environment variable CUSTOMLOCALE .


## Configuration
### In the production.rb

You need to configure the mail-server, with which the app sends emails. This concerns the lines:
  ```
  config.action_mailer.default_url_options
  config.action_mailer.smtp_settings
  ```
You need to adjust the way the config-data is read. Per default these are environment variables.

### config-data
You need to put equivalents for all files in ```config/environments/keys/development``` into environment variables (or files -> configure the production.rb accordingly), EXCEPT the private.pem. This is the private key, which should NOT be on the server in production.

* The public key for asymmetric encryption in public.pem

  Generate a private key "private.pem" on your private computer:
  ```
  openssl genrsa -des3 -out private.pem 2048
  ```
  Generate a public key based on that private key:
  ```
  openssl rsa -in private.pem -outform PEM -pubout -out public.pem
  ```
  Copy the public key onto the server into the environment variable PUBLICPEM.
  Keep the private key on your private computer to use it later for the download with [Fuse Shift Tools](https://github.com/magicjascha/fuse_shift_tools)


* You need a 256-bit-key for the symmteric encryption. E.g. you could generate it with:
  ```
  openssl enc -aes-256-cbc -k [secret] -P -md sha1
  ```
  where [secret] is some random word, for generating a random key. Don't mind the salt and initilization vector. Just put the key into the environment variable SYMKEY.

* The http-authentication-login for normal users goes into the environment variable AUTHUSERS. It has to be structured like ```config/environments/development/http_auth_users.csv```

  * The different logins are separated by line.
  * Username and password are separated by a comma.
  * Only use UTF-8 valid characters.
  * Password needs to be hashed with bcrypt.
  
    If you have ruby installed somewhere, type ```irb``` for opening the ruby console and then:
      ```
      require 'bcrypt'
      BCrypt::Password.create('password')
      ```

* Proceed analogous with the http-authentication-login for the admin(s) and the environment variable AUTHADMIN

* The specifics for the app go into the environment variable CONFIGDATA structured like ```config/keys/development/config_data.csv```: website title, deadline, festival start and end
