class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :user

  enum :role, {
    owner: "owner",
    admin: "admin",
    member: "member"
  }, default: :member, validate: true

  enum :invitation_status, {
    pending: "pending",
    accepted: "accepted",
    declined: "declined",
    revoked: "revoked"
  }, default: :accepted, validate: true

  validates :user_id, uniqueness: { scope: :group_id }

  scope :active_records, -> { where(removed_at: nil) }

  before_validation :set_joined_at_for_accepted_membership

  def removed?
    removed_at.present?
  end

  def remove!
    update!(removed_at: Time.current)
  end

  private

  def set_joined_at_for_accepted_membership
    self.joined_at ||= Time.current if accepted?
  end
end
