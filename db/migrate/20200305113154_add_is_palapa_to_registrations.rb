class AddIsPalapaToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :is_palapa, :string
  end
end
