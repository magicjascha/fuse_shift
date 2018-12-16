# require 'test_helper' #why does this not work to replace hasher and encrypt/encryptor as in registration process test
require 'hasher'
require 'encrypt/encryptor'

FactoryBot.define do
  
  factory :registration_input, class: Registration do |f|
    #required fields
    f.name { "Lisa" }
    f.email { "lisa@mail.de" }
    f.start { "2018-06-21 16:00" }#year,month,day,hour,minute
    f.end { "2018-07-05 08:00" }
    
    f.trait :all_fields do
      shortname {"kurz"}
      comment { "Das ist ein Kommentar" }
      english { true }
      french { false }
      german { true }
      is_friend { false }
      phonenumber { "1273839" }
    end
    
    f.trait :sequence do
      email
      sequence(:name) { |n| "person#{n}" }
    end
  end
  
  factory :registration, parent: :registration_input do |f|    
    f.association :contact_person, :confirmed, strategy: :build #with build no record is created. With create both records are created.
    f.contact_persons_email { contact_person.hashed_email}
    f.city { "testCity" }
    f.hashed_email { Hasher.digest(email.downcase) }
    f.after(:build) { |registration| registration.email.downcase!}
    
    f.trait :encrypted do
      after(:build) do |registration| 
        registration.name = Encrypt::Encryptor.new(registration.name, Rails.configuration.x.pem).apply      
        registration.email = Encrypt::Encryptor.new(registration.email.downcase, Rails.configuration.x.pem).apply
        registration.phonenumber = Encrypt::Encryptor.new(registration.phonenumber, Rails.configuration.x.pem).apply
        registration.contact_persons_email = Encrypt::Encryptor.new(registration.contact_persons_email, Rails.configuration.x.pem).apply
        registration.german = Encrypt::Encryptor.new(registration.german, Rails.configuration.x.pem).apply
        registration.english = Encrypt::Encryptor.new(registration.english, Rails.configuration.x.pem).apply
        registration.french = Encrypt::Encryptor.new(registration.french, Rails.configuration.x.pem).apply
        registration.is_friend = Encrypt::Encryptor.new(registration.is_friend, Rails.configuration.x.pem).apply
        registration.comment = Encrypt::Encryptor.new(registration.comment, Rails.configuration.x.pem).apply
        registration.start = Encrypt::Encryptor.new(registration.start, Rails.configuration.x.pem).apply
        registration.end = Encrypt::Encryptor.new(registration.end, Rails.configuration.x.pem).apply
      end
    end
    
    factory :saved_registration, traits: :encrypted
    
  end
  
  factory :contact_person do
    transient do
      email { "koko@mail.de" }
    end

    hashed_email { email }
    
    trait :confirmed do
      confirmed { true }
    end
    
    trait :email_hashed do
      after(:build) do |contact_person|
        contact_person.hashed_email =  Hasher.digest(contact_person.hashed_email.downcase)
      end
    end

    factory :confirmed_contact_person_record, traits: [:confirmed, :email_hashed]
    
  end
  
  sequence :email do |n|
    "person#{n}@mail.de"
  end
  

  
end


#several traits:     factory :confirmed_contact_person, traits: [:confirmed, :somethingelse]
#Usage:
#      @registration = build(:registration, contact_person: build(:confirmed_contact_person)) #specify other contact_person