class CreateForms < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :accent_color, null: false, default: "#1D4ED8"
      t.text :privacy_notice
      t.integer :retention_days, null: false, default: 90
      t.integer :monthly_submission_limit, null: false, default: 10_000
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :organizations, :slug, unique: true
    add_check_constraint :organizations,
      "slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'",
      name: "organizations_slug_format"
    add_check_constraint :organizations,
      "accent_color ~ '^#[0-9A-Fa-f]{6}$'",
      name: "organizations_accent_color_format"
    add_check_constraint :organizations,
      "retention_days BETWEEN 1 AND 365",
      name: "organizations_retention_days_range"
    add_check_constraint :organizations,
      "monthly_submission_limit BETWEEN 1 AND 100000",
      name: "organizations_monthly_limit_range"

    create_table :forms do |t|
      t.references :organization, null: false, foreign_key: true, index: { unique: true }
      t.string :name, null: false
      t.string :slug, null: false, default: "complaint"

      t.timestamps
    end

    add_index :forms, [ :organization_id, :slug ], unique: true
    add_index :forms, [ :id, :organization_id ], unique: true
  end
end
