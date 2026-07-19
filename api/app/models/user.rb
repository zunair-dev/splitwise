class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :jwt_authenticatable,
    jwt_revocation_strategy: self

  has_one_attached :avatar

  has_many :requested_friendships, class_name: "Friendship", foreign_key: :requester_id, dependent: :destroy, inverse_of: :requester
  has_many :received_friendships, class_name: "Friendship", foreign_key: :addressee_id, dependent: :destroy, inverse_of: :addressee
  has_many :created_groups, class_name: "Group", foreign_key: :created_by_id, dependent: :restrict_with_exception, inverse_of: :created_by
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :sent_group_invitations, class_name: "GroupInvitation", foreign_key: :invited_by_id, dependent: :restrict_with_exception, inverse_of: :invited_by
  has_many :created_expenses, class_name: "Expense", foreign_key: :created_by_id, dependent: :restrict_with_exception
  has_many :expense_payments, class_name: "ExpensePayer", dependent: :restrict_with_exception
  has_many :expense_shares, dependent: :restrict_with_exception

  enum :profile_status, {
    active: "active",
    deactivated: "deactivated"
  }, default: :active, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 120 }
  validates :email, length: { maximum: 255 }

  scope :active_profiles, -> { active.where(deleted_at: nil) }

  def friendships
    Friendship.involving(self)
  end

  def friends
    friend_ids = friendships.accepted.pluck(:requester_id, :addressee_id).map do |requester_id, addressee_id|
      requester_id == id ? addressee_id : requester_id
    end

    User.where(id: friend_ids)
  end
end
