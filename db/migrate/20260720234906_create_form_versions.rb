class CreateFormVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :form_versions do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :form, null: false
      t.integer :version_number, null: false
      t.integer :status, null: false, default: 0
      t.string :title, null: false
      t.text :intro
      t.text :confirmation_message
      t.datetime :published_at
      t.references :created_by, foreign_key: { to_table: :users }
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :form_versions, :forms,
      column: [ :form_id, :organization_id ],
      primary_key: [ :id, :organization_id ]
    add_index :form_versions, [ :id, :organization_id ], unique: true
    add_index :form_versions, [ :form_id, :version_number ], unique: true
    add_index :form_versions, :form_id, unique: true,
      where: "status = 0", name: "index_form_versions_one_draft"
    add_index :form_versions, :form_id, unique: true,
      where: "status = 1", name: "index_form_versions_one_published"
    add_check_constraint :form_versions, "status IN (0, 1, 2)",
      name: "form_versions_status_valid"
    add_check_constraint :form_versions, "version_number > 0",
      name: "form_versions_version_positive"
  end
end
