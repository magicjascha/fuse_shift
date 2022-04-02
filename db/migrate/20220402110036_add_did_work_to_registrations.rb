class AddDidWorkToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :did_work, :string
    add_column :registrations, :did_orga, :string
    add_column :registrations, :wants_orga, :string
  end
end
