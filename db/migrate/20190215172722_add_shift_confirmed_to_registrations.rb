class AddShiftConfirmedToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :shift_confirmed, :boolean
  end
end
