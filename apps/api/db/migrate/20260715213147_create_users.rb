class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :profile_status, null: false, default: "active"
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
    add_index :users, :deleted_at
    add_check_constraint :users, "profile_status IN ('active', 'deactivated')", name: "users_profile_status_check"
  end
end
