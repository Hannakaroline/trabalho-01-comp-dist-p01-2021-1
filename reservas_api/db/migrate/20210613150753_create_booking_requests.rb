class CreateBookingRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :booking_requests do |t|
      t.datetime :from
      t.datetime :to
      t.references :place, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :accepted, default: nil, null: true
      t.string :note, null: true
      t.references :booking, default: nil, null: true, foreign_key: true

      t.timestamps
    end
  end
end
