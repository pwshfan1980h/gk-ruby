class CreateFormFields < ActiveRecord::Migration[8.1]
  def change
    create_table :form_fields do |t|
      t.references :form_version, null: false, foreign_key: true
      t.string :field_key, null: false
      t.integer :field_type, null: false
      t.string :label, null: false
      t.text :help_text
      t.string :placeholder
      t.boolean :required, null: false, default: false
      t.integer :position, null: false, default: 0
      t.integer :max_length
      t.jsonb :options, null: false, default: []

      t.timestamps
    end

    add_index :form_fields, [ :form_version_id, :field_key ], unique: true
    add_index :form_fields, [ :form_version_id, :position ]
    add_check_constraint :form_fields, "field_type BETWEEN 0 AND 8",
      name: "form_fields_type_valid"
    add_check_constraint :form_fields, "position BETWEEN 0 AND 29",
      name: "form_fields_position_range"
    add_check_constraint :form_fields,
      "max_length IS NULL OR max_length BETWEEN 1 AND 5000",
      name: "form_fields_max_length_range"
  end
end
