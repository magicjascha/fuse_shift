class AddMissingColumnsToRegistrations < ActiveRecord::Migration[5.1]
  def change
    add_column :registrations, :shortname, :text
    add_column :registrations, :german, :boolean
    add_column :registrations, :english, :boolean
    add_column :registrations, :french, :boolean
    add_column :registrations, :comment, :text
    add_column :registrations, :start, :timestamp
    add_column :registrations, :end, :timestamp
  end
end
