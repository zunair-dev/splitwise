class ExpenseShare < ApplicationRecord
  belongs_to :expense
  belongs_to :user
  validates :user_id, uniqueness: { scope: :expense_id }
  validates :amount_minor, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :percentage_basis_points, numericality: { only_integer: true, in: 0..10_000 }, allow_nil: true
  validates :share_units, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
