class ExpensePayer < ApplicationRecord
  belongs_to :expense
  belongs_to :user
  validates :user_id, uniqueness: { scope: :expense_id }
  validates :amount_minor, numericality: { only_integer: true, greater_than: 0 }
end
