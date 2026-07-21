class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    enable_extension "citext" unless extension_enabled?("citext")

    create_table :users do |t|
      t.citext :email_address, null: false
      t.string :password_digest, null: false
      t.string :name, null: false
      t.datetime :last_sign_in_at

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
