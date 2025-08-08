class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :provider
      t.string :provider_payment_id
      t.integer :amount_cents
      t.string :status
      t.json :metadata

      t.timestamps
    end
  end
end
