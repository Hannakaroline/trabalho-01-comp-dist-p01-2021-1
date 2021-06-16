class CreatePlaceAdmins < ActiveRecord::Migration[6.1]
  def change
    create_table :place_admins do |t|
      t.references :user, null: false, foreign_key: true
      t.references :place, null: false, foreign_key: true

      t.timestamps
    end
  end
end
