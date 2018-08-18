class CreateContactPeople < ActiveRecord::Migration[5.1]
  def change
    create_table :contact_people do |t|
      t.string :hashed_email
      t.boolean :confirmed

      t.timestamps
    end
  end
end
