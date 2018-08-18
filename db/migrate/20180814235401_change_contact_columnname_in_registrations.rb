class ChangeContactColumnnameInRegistrations < ActiveRecord::Migration[5.1]
  def change
    rename_column :registrations, :contact_person, :contact_persons_email
  end
end
