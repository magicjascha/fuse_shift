class ChangeDataTypesForFieldnames < ActiveRecord::Migration[5.1]
  def change
    change_column :registrations, :english, :string
    change_column :registrations, :french, :string
    change_column :registrations, :german, :string
    change_column :registrations, :is_friend, :string
  end
end
