class AddDeviseJwtToUsers < ActiveRecord::Migration[8.1]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    rename_column :users, :password_digest, :encrypted_password
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :remember_created_at, :datetime
    add_column :users, :jti, :string, null: false, default: -> { "gen_random_uuid()" }

    add_index :users, :reset_password_token, unique: true
    add_index :users, :jti, unique: true
  end

  def down
    remove_index :users, :jti
    remove_index :users, :reset_password_token

    remove_column :users, :jti
    remove_column :users, :remember_created_at
    remove_column :users, :reset_password_sent_at
    remove_column :users, :reset_password_token
    rename_column :users, :encrypted_password, :password_digest
  end
end
