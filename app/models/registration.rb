#todo: 
# validations: 
# phone-number digits and dashes.
# is_friend, city
# add uniqueness on database level for hashed email

require 'encrypt/encryptor'
require 'digest'

class Registration < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
 
  #for update only the attributes where the user puts input will be validated.
  validates :hashed_email, uniqueness: { case_sensitive: false, message: :uniqueness }, if: proc { |r| r.hashed_email_changed? }
  validates :name, presence: true, length: { maximum: 50 }, if: proc { |r| r.name_changed? }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.email_changed? }
  validates :phonenumber, presence: true, length: { maximum: 20 }, if: proc { |r| r.phonenumber_changed? }
  validates :contact_person, presence: true, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.contact_person_changed? }
  validates_datetime :start, :before => lambda { FESTIVAL_END }
  validates_datetime :end, :after => lambda { FESTIVAL_START}
  validates_datetime :start, :on_or_before => :end
end
