require 'hasher'

FactoryBot.define do
  factory :registration do
    name "John"
    email  "Doe@does.de"
    phonenumber "1234"
    is_member false
    city "Berlin"
    hashedEmail Hasher.digest("Doe@does.de")
  end  
end
