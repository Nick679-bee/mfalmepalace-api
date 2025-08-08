class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.date :check_in
      t.date :check_out
      t.integer :guests_count
      t.integer :price_cents
      t.string :currency
      t.string :status
      t.string :payment_status
      t.text :special_requests

      t.timestamps
    end
  end
end
