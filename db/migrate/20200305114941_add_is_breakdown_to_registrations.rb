class AddIsBreakdownToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :is_breakdown, :string
  end
end
