class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.string :name
      t.string :property_type
      t.text :description
      t.integer :max_guests
      t.json :amenities
      t.integer :distance_to_airport_minutes
      t.boolean :pet_friendly
      t.boolean :eco_friendly
      t.text :photos

      t.timestamps
    end
  end
end
