require 'travis/encrypt'

class Registration < ApplicationRecord
  def to_csv
    CSV.open("#{Rails.root}/public/registration_#{self.created_at.strftime('%Y-%m-%dT%H%M%S')}.csv", "wb") do |csv|
      csv << self.attributes.keys
      csv << self.attributes.values
    end
  end

  def name=(name)
    puts "name is: #{name} in Registration"
    key = "c35237aa3793ac9c22c60eb32291291f8da40b02fae9f0519085a33765f23729cb00be6804097724ddc0a7b30e924cf0bed51c35b1a306857519294cd2ab053b"
    name = Travis::Encrypt::Encryptor.new(name, key: key).apply
    puts name
    super(name)
  end
end
