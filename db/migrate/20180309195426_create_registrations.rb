class CreateRegistrations < ActiveRecord::Migration[5.1]
  def change
    create_table :registrations do |t|
      t.string :name
      t.string :email
      t.string :phonenumber
      t.boolean :is_member
      t.string :contact_person
      t.string :city

      t.timestamps
    end
  end
end
