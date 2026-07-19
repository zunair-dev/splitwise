class CreateFriendships < ActiveRecord::Migration[8.1]
  def change
    create_table :friendships do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :addressee, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending"
      t.datetime :accepted_at
      t.datetime :blocked_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :friendships,
      "LEAST(requester_id, addressee_id), GREATEST(requester_id, addressee_id)",
      unique: true,
      name: "index_friendships_on_user_pair"
    add_index :friendships, :status
    add_index :friendships, :deleted_at
    add_check_constraint :friendships, "requester_id <> addressee_id", name: "friendships_distinct_users_check"
    add_check_constraint :friendships, "status IN ('pending', 'accepted', 'blocked')", name: "friendships_status_check"
  end
end
