class CreateGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :group_memberships do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "member"
      t.string :invitation_status, null: false, default: "accepted"
      t.datetime :joined_at
      t.datetime :removed_at

      t.timestamps
    end

    add_index :group_memberships, [ :group_id, :user_id ], unique: true
    add_index :group_memberships, :role
    add_index :group_memberships, :invitation_status
    add_index :group_memberships, :removed_at
    add_check_constraint :group_memberships, "role IN ('owner', 'admin', 'member')", name: "group_memberships_role_check"
    add_check_constraint :group_memberships, "invitation_status IN ('pending', 'accepted', 'declined', 'revoked')", name: "group_memberships_invitation_status_check"
  end
end
