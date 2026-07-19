class CreateExpenseLedger < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :group, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :description, null: false
      t.text :notes
      t.bigint :amount_minor, null: false
      t.string :currency_code, null: false, default: "USD", limit: 3
      t.date :expense_date, null: false
      t.string :split_method, null: false, default: "equal"
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :expenses, [ :group_id, :expense_date ]
    add_index :expenses, :deleted_at
    add_check_constraint :expenses, "amount_minor > 0", name: "expenses_positive_amount"
    add_check_constraint :expenses, "currency_code ~ '^[A-Z]{3}$'", name: "expenses_currency_code_format"
    add_check_constraint :expenses, "split_method IN ('equal', 'exact', 'percentage', 'shares')", name: "expenses_split_method_check"

    create_table :expense_payers do |t|
      t.references :expense, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.bigint :amount_minor, null: false
      t.timestamps
    end
    add_index :expense_payers, [ :expense_id, :user_id ], unique: true
    add_check_constraint :expense_payers, "amount_minor > 0", name: "expense_payers_positive_amount"

    create_table :expense_shares do |t|
      t.references :expense, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.bigint :amount_minor, null: false
      t.integer :percentage_basis_points
      t.integer :share_units
      t.timestamps
    end
    add_index :expense_shares, [ :expense_id, :user_id ], unique: true
    add_check_constraint :expense_shares, "amount_minor >= 0", name: "expense_shares_nonnegative_amount"
    add_check_constraint :expense_shares, "percentage_basis_points IS NULL OR percentage_basis_points BETWEEN 0 AND 10000", name: "expense_shares_percentage_range"
    add_check_constraint :expense_shares, "share_units IS NULL OR share_units > 0", name: "expense_shares_positive_units"
  end
end
