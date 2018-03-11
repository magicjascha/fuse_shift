class Registration < ApplicationRecord
  def to_csv
    CSV.open("#{Rails.root}/public/registration_#{self.created_at.strftime('%Y-%m-%dT%H%M%S')}.csv", "wb") do |csv|
      csv << self.attributes.keys
      csv << self.attributes.values
    end
  end
end
