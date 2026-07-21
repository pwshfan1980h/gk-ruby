class CreateSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :submissions do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :form_version, null: false
      t.string :reference_number, null: false
      t.integer :status, null: false, default: 0
      t.jsonb :answers, null: false, default: {}
      t.datetime :submitted_at, null: false
      t.datetime :retained_until, null: false
      t.string :submitter_ip_digest
      t.string :user_agent

      t.timestamps
    end

    add_foreign_key :submissions, :form_versions,
      column: [ :form_version_id, :organization_id ],
      primary_key: [ :id, :organization_id ]
    add_index :submissions, :reference_number, unique: true
    add_index :submissions, [ :organization_id, :submitted_at ]
    add_index :submissions, [ :organization_id, :status, :submitted_at ]
    add_index :submissions, :retained_until
    add_check_constraint :submissions, "status IN (0, 1, 2)",
      name: "submissions_status_valid"
  end
end
