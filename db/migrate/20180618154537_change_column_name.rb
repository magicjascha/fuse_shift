class ChangeColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :registrations, :hashedEmail, :hashed_email
    rename_column :registrations, :is_member, :is_friend
  end
end
