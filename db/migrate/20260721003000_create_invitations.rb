class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.citext :email_address, null: false
      t.integer :role, null: false, default: 1
      t.datetime :expires_at, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :invitations, [ :organization_id, :email_address ], unique: true,
      where: "accepted_at IS NULL", name: "index_invitations_one_pending_per_email"
    add_index :invitations, :expires_at
    add_check_constraint :invitations, "role IN (0, 1)",
      name: "invitations_role_valid"
  end
end
