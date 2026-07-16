class Friendship < ApplicationRecord
  belongs_to :requester, class_name: "User", inverse_of: :requested_friendships
  belongs_to :addressee, class_name: "User", inverse_of: :received_friendships

  enum :status, {
    pending: "pending",
    accepted: "accepted",
    blocked: "blocked"
  }, default: :pending, validate: true

  validates :requester, uniqueness: { scope: :addressee_id }
  validate :users_are_distinct
  validate :friendship_pair_is_unique, on: :create

  scope :active_records, -> { where(deleted_at: nil) }
  scope :involving, ->(user) { where(requester: user).or(where(addressee: user)) }

  def accept!
    update!(status: :accepted, accepted_at: Time.current)
  end

  def block!
    update!(status: :blocked, blocked_at: Time.current)
  end

  private

  def users_are_distinct
    errors.add(:addressee, "must be different from requester") if requester_id.present? && requester_id == addressee_id
  end

  def friendship_pair_is_unique
    return if requester_id.blank? || addressee_id.blank?

    low_user_id, high_user_id = [ requester_id, addressee_id ].minmax
    existing_pair = Friendship
      .where.not(id:)
      .where("LEAST(requester_id, addressee_id) = ? AND GREATEST(requester_id, addressee_id) = ?", low_user_id, high_user_id)
      .exists?

    errors.add(:base, "friendship already exists for these users") if existing_pair
  end
end
