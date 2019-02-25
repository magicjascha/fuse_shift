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

  #VALIDATIONS only when non-nil attributes will be validated.
  

  validates :name, presence: true, length: { maximum: 50 }, if: proc { |r| r.name_changed? }
  validates :contact_persons_email, presence: true, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.contact_persons_email_changed? }  
  validates :hashed_email, 
    :uniqueness => { case_sensitive: false },
    :if => proc { |r| r.hashed_email_changed? && r.email.present?}
  validate :change_hashed_email_error_to_email
  validates :email, presence: true, if: proc { |r| r.email_changed? }
  validates :email, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.email_changed? && r.email.present?}
  ##DATE validations
  #start and end dates should be present
  validates(:start, presence: true, :if => proc { |r| r.start_changed? })
  validates(:end, presence: true, :if => proc { |r| r.end_changed? })
#   validate :email_not_used_before
# start should be after festival-start
#   validates_datetime(:start, :on_or_before => lambda { Rails.configuration.x.festival_end },
#                              :on_or_after => lambda { Rails.configuration.x.festival_start },
#                              :if => proc { |r| r.start_changed? && r.start!=""})
#   #end should be after festival-start
#   validates_datetime(:end, :on_or_after => lambda { Rails.configuration.x.festival_start },
#                            :on_or_before => lambda { Rails.configuration.x.festival_end}, 
#                            :if => proc { |r| r.end_changed? && r.end!=""})
# # start should be before end
#   validates_datetime( :start, :before => :end, 
#                               :if => proc { |r| r.start_changed? and r.end_changed? },
#                               :unless => proc {|r| r.end=="" || r.start==""})
  
  def change_hashed_email_error_to_email
    if errors.messages[:hashed_email]!=[]
      errors.add(:email, :uniqueness)
      self.errors.delete(:hashed_email)
    end
  end

end
