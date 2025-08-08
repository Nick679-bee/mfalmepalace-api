class CreatePriceOverrides < ActiveRecord::Migration[8.0]
  def change
    create_table :price_overrides do |t|
      t.references :property, null: false, foreign_key: true
      t.date :date
      t.integer :price_cents
      t.boolean :is_blackout

      t.timestamps
    end
  end
end
