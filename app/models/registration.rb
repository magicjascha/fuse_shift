require 'travis/encrypt'

class Registration < ApplicationRecord
  # sets the user’s email address to lower-case, as some database adapters use case-sensitive indices
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  # regex = regular expression, language for matching patterns in strings
  # used to match valid email addresses while not matching invalid ones
  # TODO FIX: the following regex allows invalid addresses that contain consecutive dots, such as foo@bar..com.
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  #  Active Record uniqueness validation does not guarantee uniqueness at the database level!
  # How important is uniqueness of E-Mail?

  # TODO: Add regular expression that prevents submitting of letters (+,/ needs to be allowed)!
  validates :phonenumber, presence: true, length: { maximum: 20 }

  def to_csv
    CSV.open("#{Rails.root}/public/registration_#{self.created_at.strftime('%Y-%m-%dT%H%M%S')}.csv", "wb") do |csv|
      csv << self.attributes.keys
      csv << self.attributes.values
    end
  end

  # def name=(name)
  #   puts "name is: #{name} in Registration"
  #   key = "c35237aa3793ac9c22c60eb32291291f8da40b02fae9f0519085a33765f23729cb00be6804097724ddc0a7b30e924cf0bed51c35b1a306857519294cd2ab053b"
  #   name = Travis::Encrypt::Encryptor.new(name, key: key).apply
  #   puts name
  #   super(name)
  # end
end
