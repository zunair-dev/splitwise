class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.text :description
      t.string :group_type, null: false, default: "other"
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.datetime :archived_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :groups, :group_type
    add_index :groups, :archived_at
    add_index :groups, :deleted_at
    add_check_constraint :groups, "group_type IN ('trip', 'household', 'partner', 'family', 'friends', 'other')", name: "groups_group_type_check"
  end
end
