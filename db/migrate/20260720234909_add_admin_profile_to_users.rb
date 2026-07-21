class AddAdminProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 1
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :memberships, [ :organization_id, :user_id ], unique: true
    add_check_constraint :memberships, "role IN (0, 1)",
      name: "memberships_role_valid"

    create_table :audit_events do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.string :auditable_type
      t.bigint :auditable_id
      t.jsonb :metadata, null: false, default: {}
      t.string :ip_digest
      t.datetime :created_at, null: false
    end

    add_index :audit_events, [ :organization_id, :created_at ]
    add_index :audit_events, [ :auditable_type, :auditable_id ]
    add_check_constraint :audit_events, "char_length(action) BETWEEN 1 AND 100",
      name: "audit_events_action_length"
  end
end
