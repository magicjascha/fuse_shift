#todo: 
# validations: phone-number digits and dashes.
# add uniqueness on database level for hashed email

require 'encrypt/encryptor'
require 'digest'

class Registration < ApplicationRecord
  include Hasher  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  before_save on: :create do
    self.email = email.downcase
    self.hashedEmail = digest(email)
    p changes
  end
  
  validates :hashedEmail, uniqueness: { case_sensitive: false }, if: proc { |r| r.hashedEmail_changed? }
  validates :name, presence: true, length: { maximum: 50 }, if: proc { |r| r.name_changed? }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.email_changed? }
  validates :phonenumber, presence: true, length: { maximum: 20 }, if: proc { |r| r.phonenumber_changed? }
  
  
#   before_save do
#     attributes = self.attribute_names - ["id", "created_at", "updated_at", "is_member", "hashedEmail"]
#     attributes.each do |attribute|
#       value = self[attribute]
#       key = File.read('config/keys/public.dev.pem')
# #       key = "c35237aa3793ac9c22c60eb32291291f8da40b02fae9f0519085a33765f23729cb00be6804097724ddc0a7b30e924cf0bed51c35b1a306857519294cd2ab053b"
#       value = Encrypt::Encryptor.new(value, key).apply
#       self[attribute] = value 
#     end
#   end
  


  # def name=(name)
  #   puts "name is: #{name} in Registration"
  #   key = "c35237aa3793ac9c22c60eb32291291f8da40b02fae9f0519085a33765f23729cb00be6804097724ddc0a7b30e924cf0bed51c35b1a306857519294cd2ab053b"
  #   name = Travis::Encrypt::Encryptor.new(name, key: key).apply
  #   puts name
  #   super(name)
  # end
end
