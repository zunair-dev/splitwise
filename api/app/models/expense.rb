class Expense < ApplicationRecord
  belongs_to :group
  belongs_to :created_by, class_name: "User"
  has_many :expense_payers, dependent: :destroy
  has_many :payers, through: :expense_payers, source: :user
  has_many :expense_shares, dependent: :destroy
  has_many :participants, through: :expense_shares, source: :user

  enum :split_method, { equal: "equal", exact: "exact", percentage: "percentage", shares: "shares" }, default: :equal, validate: true

  normalizes :description, with: ->(value) { value.strip }
  normalizes :currency_code, with: ->(value) { value.strip.upcase }

  validates :description, presence: true, length: { maximum: 255 }
  validates :notes, length: { maximum: 5_000 }, allow_blank: true
  validates :amount_minor, numericality: { only_integer: true, greater_than: 0 }
  validates :currency_code, format: { with: /\A[A-Z]{3}\z/ }
  validates :expense_date, presence: true

  scope :active_records, -> { where(deleted_at: nil) }

  def discard! = update!(deleted_at: Time.current)
  def restore! = update!(deleted_at: nil)
end
