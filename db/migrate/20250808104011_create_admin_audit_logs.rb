class CreateAdminAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_audit_logs do |t|
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.string :action
      t.json :details

      t.timestamps
    end
  end
end
