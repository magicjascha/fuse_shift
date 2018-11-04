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
  validates :email, presence: true, if: proc { |r| r.email_changed? }
  validates :email, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.email_changed? && r.email.present?}
  validates :contact_persons_email, presence: true, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.contact_persons_email_changed? }
  #start and end dates should be present
#   validates(:start, presence: true, :if => proc { |r| r.start_changed? })
#   validates(:end, presence: true, :if => proc { |r| r.end_changed? })

  validate :start_date_presence
  validate :end_date_presence 
  #  start should be after festival-start
  validates_datetime(:start, :on_or_before => lambda { Rails.configuration.x.festival_end },
                             :on_or_after => lambda { Rails.configuration.x.festival_start },
                             :if => proc { |r| r.start_changed? },
                             :unless => proc {|r| date_is_empty_at_create?(r.start)})
  #end should be after festival-start
  validates_datetime(:end, :on_or_after => lambda { Rails.configuration.x.festival_start },
                           :on_or_before => lambda { Rails.configuration.x.festival_end}, 
                           :if => proc { |r| r.end_changed? },
                           :unless => proc {|r| date_is_empty_at_create?(r.end)})
  #start should be before end
  validates_datetime( :start, :before => :end, 
                              :if => proc { |r| r.start_changed? and r.end_changed? },
#                               :unless => date_is_empty_at_create?(self.end))
                              :unless => proc {|r| date_is_empty_at_create?(r.end) || date_is_empty_at_create?(r.start)})
  
  def date_is_empty_at_create?(dateString)
    if dateString
      DateTime.parse(dateString) == DateTime.parse("1970-01-01 15:00:00 UTC")
    else
      false
    end
  end
  
  def start_date_presence
    if date_is_empty_at_create?(self.start)
      errors.add(:start, "can't be blank")
    end
  end
  
  def end_date_presence
    if date_is_empty_at_create?(self.end)
      errors.add(:end, "can't be blank")
    end
  end
  
end
