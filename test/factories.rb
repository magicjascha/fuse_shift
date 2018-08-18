# require 'test_helper' #why does this not work to replace hasher and encrypt/encryptor as in registration process test
require 'hasher'
require 'encrypt/encryptor'

FactoryBot.define do
  
  factory :registration do |f|
    
    f.name "Lisa"
    f.email "lisa@mail.de"
    f.phonenumber "3839"
    f.is_friend true
    f.contact_persons_email "koko@mail.de"
    f.city "Hamburg"
    f.start DateTime.new(2018,6,21,16,0)
    f.end DateTime.new(2018,7,5,8,0)
    association :contact_person, :confirmed, strategy: :build #with build no record is created. With create both records are created.
    
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
        registration.contact_persons_email = Encrypt::Encryptor.new(registration.contact_persons_email, Rails.configuration.x.pem).apply
        registration.city = Encrypt::Encryptor.new(registration.city, Rails.configuration.x.pem).apply
      end
    end
    
    factory :saved_registration, traits: :as_record
    
  end
  
  factory :contact_person do |f|
    
    f.hashed_email "koko@mail.de"
    
    f.trait :confirmed do
      confirmed true
    end
    
    f.trait :as_record do
      after(:build) do |contact_person|
        contact_person.hashed_email =  Hasher.digest(contact_person.hashed_email.downcase)
      end
    end

    factory :confirmed_contact_person, traits: [:confirmed, :as_record]
    
  end
  
end


#several traits:     factory :confirmed_contact_person, traits: [:confirmed, :somethingelse]
#Usage:
#      @registration = build(:registration, contact_person: build(:confirmed_contact_person)) #specify other contact_person