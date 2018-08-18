class AddContactPersonIdToRegistrations < ActiveRecord::Migration[5.1]
  def change
    add_reference :registrations, :contact_person_id, foreign_key: true
  end
end
