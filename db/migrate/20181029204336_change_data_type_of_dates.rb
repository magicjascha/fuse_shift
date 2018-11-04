class ChangeDataTypeOfDates < ActiveRecord::Migration[5.1]
  def change
    change_column :registrations, :start, :string
    change_column :registrations, :end, :string
  end
end
