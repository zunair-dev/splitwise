class AddCategoryToExpenses < ActiveRecord::Migration[8.1]
  CATEGORIES = %w[general food_drink groceries transportation accommodation utilities entertainment shopping].freeze

  def change
    add_column :expenses, :category, :string, null: false, default: "general"
    add_index :expenses, :category
    add_check_constraint :expenses, "category IN (#{CATEGORIES.map { |category| connection.quote(category) }.join(', ')})", name: "expenses_category_check"
  end
end
