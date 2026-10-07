class AddUniqueIndexesForUserProfiles < ActiveRecord::Migration[8.1]
  def change
    # one doctor / patient profile per user, one account per email
    remove_index :doctors, :user_id
    add_index :doctors, :user_id, unique: true
    remove_index :patients, :user_id
    add_index :patients, :user_id, unique: true
    add_index :users, :email, unique: true
  end
end
