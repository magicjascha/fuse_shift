class AddSecuOptionsToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :has_secu, :string
    add_column :registrations, :has_secu_registered, :string
    add_column :registrations, :wants_guard, :string
    add_column :registrations, :real_forename, :string
    add_column :registrations, :real_lastname, :string
  end
end
