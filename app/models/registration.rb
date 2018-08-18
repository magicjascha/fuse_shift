# add uniqueness on database level for hashed email

require 'encrypt/encryptor'
require 'digest'

class Registration < ApplicationRecord
  #Makes url and path_helpers work with hashed_email instead of id
  def to_param
    hashed_email
  end
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  belongs_to :contact_person
 
  #for update only the attributes where the user puts input will be validated.
  validates :hashed_email, uniqueness: { case_sensitive: false, message: :uniqueness }, if: proc { |r| r.hashed_email_changed? }
  validates :name, presence: true, length: { maximum: 50 }, if: proc { |r| r.name_changed? }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.email_changed? }
  validates :contact_persons_email, presence: true, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.contact_persons_email_changed? }
  validates_datetime :start, :on_or_before => lambda { Rails.configuration.x.festival_end },
                             :on_or_after => lambda { Rails.configuration.x.festival_start }
  validates_datetime :end, :on_or_after => lambda { Rails.configuration.x.festival_start },
                           :on_or_before => lambda { Rails.configuration.x.festival_end}
  validates_datetime :start, :before => :end
end
