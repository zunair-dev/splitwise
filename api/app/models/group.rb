class Group < ApplicationRecord
  belongs_to :created_by, class_name: "User", inverse_of: :created_groups

  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user
  has_many :group_invitations, dependent: :destroy
  has_many :expenses, dependent: :restrict_with_exception

  enum :group_type, {
    trip: "trip",
    household: "household",
    partner: "partner",
    family: "family",
    friends: "friends",
    other: "other"
  }, default: :other, validate: true

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 2_000 }, allow_blank: true

  after_create :add_owner_membership

  scope :active_records, -> { where(archived_at: nil, deleted_at: nil) }

  def archived?
    archived_at.present?
  end

  def archive!
    update!(archived_at: Time.current)
  end

  private

  def add_owner_membership
    group_memberships.create!(
      user: created_by,
      role: :owner,
      invitation_status: :accepted,
      joined_at: Time.current
    )
  end
end
