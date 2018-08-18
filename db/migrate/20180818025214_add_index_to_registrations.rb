class AddIndexToRegistrations < ActiveRecord::Migration[5.1]
  def change
    add_index :registrations, :hashed_email, :unique => true
  end
end
