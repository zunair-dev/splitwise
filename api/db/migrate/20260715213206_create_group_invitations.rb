class CreateGroupInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :group_invitations do |t|
      t.references :group, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.string :role, null: false, default: "member"
      t.string :status, null: false, default: "pending"
      t.datetime :accepted_at
      t.datetime :declined_at
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :group_invitations,
      "group_id, lower(email)",
      unique: true,
      where: "status = 'pending'",
      name: "index_pending_group_invitations_on_group_and_email"
    add_index :group_invitations, :status
    add_check_constraint :group_invitations, "role IN ('admin', 'member')", name: "group_invitations_role_check"
    add_check_constraint :group_invitations, "status IN ('pending', 'accepted', 'declined', 'revoked')", name: "group_invitations_status_check"
  end
end
