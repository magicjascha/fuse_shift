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
  validates :shortname, presence: true, length: { maximum: 50 }, if: proc { |r| r.shortname_changed? }
  validates :contact_persons_email, presence: true, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.contact_persons_email_changed? }  
  validates :hashed_email, 
    :uniqueness => { case_sensitive: false },
    :if => proc { |r| r.hashed_email_changed? && r.email.present?}
  validate :change_hashed_email_error_to_email
  validates :email, presence: true, if: proc { |r| r.email_changed? }
  validates :email, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, if: proc { |r| r.email_changed? && r.email.present?}
  ##DATE validations
  validates(:start, presence: true, :if => proc { |r| r.start_changed? })
  validate :valid_start_date_format, :if => proc { |r| r.end_changed? }
  validate :start_date_in_festival_time, :if => proc { |r| r.start_changed? }
  validate :start_date_before_end_date, :if => proc { |r| r.start_changed? and r.end_changed?}
  validates(:end, presence: true, :if => proc { |r| r.end_changed? })
  validate :valid_end_date_format, :if => proc { |r| r.end_changed? }
  validate :end_date_in_festival_time, :if => proc { |r| r.end_changed? }

  
  def change_hashed_email_error_to_email
    if errors.messages[:hashed_email]!=[]
      errors.add(:email, :uniqueness)
      self.errors.delete(:hashed_email)
    end
  end
  
  def start_date_before_end_date
    if valid_date?(self[:start]) and valid_date?(self[:end])
      startdate = DateTime.parse(self[:start])
      enddate = DateTime.parse(self[:end])
      if startdate > enddate or startdate==enddate
        errors.add(:start, I18n.t("activerecord.errors.custom.before_end", end_label: I18n.t("activerecord.attributes.registration.end")))
      end
    end
  end
  
  def start_date_in_festival_time
    if not_in_festival_time(self[:start])
      errors.add(:start, I18n.t("activerecord.errors.custom.not_in_festival_time"))
    end
  end
  
  def end_date_in_festival_time
    if not_in_festival_time(self[:end])
      errors.add(:end, I18n.t("activerecord.errors.custom.not_in_festival_time"))
    end
  end
  
  def valid_end_date_format
     message = I18n.t("activerecord.errors.custom.invalid_date_format", exampledate: I18n.l(DateTime.now, format: :datetime2))
    errors.add(:end, message) if invalid_date_format?(self[:end])
  end
  
  def valid_start_date_format
     message = I18n.t("activerecord.errors.custom.invalid_date_format", exampledate: I18n.l(DateTime.now, format: :datetime2))
    errors.add(:start, message) if invalid_date_format?(self[:start])
  end
  
  def not_in_festival_time(dateInput)
    if valid_date?(dateInput)
      date = DateTime.parse(dateInput)
      date > Rails.configuration.x.festival_end or date < Rails.configuration.x.festival_start ? true : false
    end
  end
  
  def valid_date?(dateInput)
    dateInput.present? and !invalid_date_format?(dateInput)
  end
  
  def invalid_date_format?(dateInput)
    if dateInput.present?
      regex = /#{I18n.t("time.formats.datetime2_regex")}/ 
      format_ok = dateInput.match(regex)
      parseable = DateTime.strptime(dateInput, "%Y-%m-%d %H:%M") rescue false
      (format_ok and parseable) ? false : true
    end
  end
  
end
