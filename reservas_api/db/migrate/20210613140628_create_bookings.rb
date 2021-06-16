class CreateBookings < ActiveRecord::Migration[6.1]
  def change
    create_table :bookings do |t|
      t.datetime :from
      t.datetime :to
      t.boolean :cancelled, default: false, null: false
      t.references :place, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :approved_by_user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
