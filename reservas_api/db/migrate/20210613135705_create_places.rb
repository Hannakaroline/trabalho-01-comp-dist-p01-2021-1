class CreatePlaces < ActiveRecord::Migration[6.1]
  def change
    create_table :places do |t|
      t.string :name
      t.string :address
      t.boolean :auto_accept, default: false
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end
