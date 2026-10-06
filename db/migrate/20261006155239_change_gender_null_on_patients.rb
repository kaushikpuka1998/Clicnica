class ChangeGenderNullOnPatients < ActiveRecord::Migration[8.1]
  def change
    change_column_null :patients, :gender, false
  end
end
