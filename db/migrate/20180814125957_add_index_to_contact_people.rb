class AddIndexToContactPeople < ActiveRecord::Migration[5.1]
  def change
    add_index :contact_people, :hashed_email, :unique => true
  end
end
