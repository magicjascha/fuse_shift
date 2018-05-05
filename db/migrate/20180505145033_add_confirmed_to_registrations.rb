class AddConfirmedToRegistrations < ActiveRecord::Migration[5.1]
  def change
    add_column :registrations, :confirmed, :boolean
  end
end
