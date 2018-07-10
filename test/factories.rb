# require 'test_helper' #why does this not work to replace hasher and encrypt/encryptor as in registration process test
require 'hasher'
require 'encrypt/encryptor'

FactoryBot.define do
  
  factory :registration do |f|
    
    f.name "Lisa"
    f.email "Lisa@does.de"
    f.phonenumber "3839"
    f.is_friend true
    f.contact_person "Mareike@mail.de"
    f.city "Hamburg"
    f.start DateTime.new(2018,6,21,16,0)
    f.end DateTime.new(2018,7,5,8,0)
    
    f.trait :with_hashed_email do
      hashed_email { Hasher.digest(email.downcase) }
      after(:build) { |registration| registration.email.downcase!}
    end
    
    f.trait :as_record do
      with_hashed_email
      after(:build) do |registration| 
        registration.name = Encrypt::Encryptor.new(registration.name, Rails.configuration.x.pem).apply      
        registration.email = Encrypt::Encryptor.new(registration.email.downcase, Rails.configuration.x.pem).apply
        registration.phonenumber = Encrypt::Encryptor.new(registration.phonenumber, Rails.configuration.x.pem).apply
        registration.contact_person = Encrypt::Encryptor.new(registration.contact_person, Rails.configuration.x.pem).apply
        registration.city = Encrypt::Encryptor.new(registration.city, Rails.configuration.x.pem).apply
      end
    end
  end
end