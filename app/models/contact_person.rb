class ContactPerson < ApplicationRecord
  def to_param
    hashed_email
  end
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  has_many :registrations
  
  validates :hashed_email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }
end
