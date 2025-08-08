class HardeningIndexesAndJsonb < ActiveRecord::Migration[8.0]
  def up
    # Ensure photos stored as jsonb array with default []
    change_column :properties, :photos, :jsonb, using: 'photos::jsonb', default: [], null: false

    # Ensure amenities is jsonb array with default []
    change_column :properties, :amenities, :jsonb, using: 'amenities::jsonb', default: [], null: false

    # Unique email on users
    add_index :users, :email, unique: true

    # Booking range and lookups
    add_index :bookings, [:property_id, :check_in, :check_out]

    # Price overrides unique per day per property
    add_index :price_overrides, [:property_id, :date], unique: true
  end

  def down
    remove_index :price_overrides, column: [:property_id, :date]
    remove_index :bookings, column: [:property_id, :check_in, :check_out]
    remove_index :users, :email
    change_column :properties, :amenities, :jsonb, using: 'amenities', default: nil, null: true
    change_column :properties, :photos, :text, using: 'photos::text', null: true
  end
end


