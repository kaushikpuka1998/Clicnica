class AddGenderToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :gender, :string, null: false
  end
end
