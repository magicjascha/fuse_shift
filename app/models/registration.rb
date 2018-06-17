#todo: 
# validations: 
# phone-number digits and dashes.
# is_member, city
# add uniqueness on database level for hashed email

require 'encrypt/encryptor'
require 'digest'

class Registration < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  festival_start = I18n.t('festival_start').to_datetime
  festival_end = I18n.t('festival_end').to_datetime
 
  #for update only the attributes where the user puts input will be validated.
  validates :hashedEmail, uniqueness: { case_sensitive: false, message: :uniqueness }, if: proc { |r| r.hashedEmail_changed? }
  validates :name, presence: true, length: { maximum: 50 }, if: proc { |r| r.name_changed? }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.email_changed? }
  validates :phonenumber, presence: true, length: { maximum: 20 }, if: proc { |r| r.phonenumber_changed? }
  validates :contact_person, presence: true, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.contact_person_changed? }
  validates_datetime :start, :before => lambda{ festival_end}
  validates_datetime :end, :after => lambda{festival_start}
  validates_datetime :start, :on_or_before => :end
  p 
end
