class AddIsConstructionToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :is_construction, :string
  end
end
