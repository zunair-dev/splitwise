class GroupInvitation < ApplicationRecord
  belongs_to :group
  belongs_to :invited_by, class_name: "User", inverse_of: :sent_group_invitations

  enum :role, {
    admin: "admin",
    member: "member"
  }, default: :member, validate: true

  enum :status, {
    pending: "pending",
    accepted: "accepted",
    declined: "declined",
    revoked: "revoked"
  }, default: :pending, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :group_id, case_sensitive: false, conditions: -> { pending } }, if: :pending?

  scope :active_records, -> { pending }

  def accept!(user)
    transaction do
      update!(status: :accepted, accepted_at: Time.current)
      group.group_memberships.create!(
        user: user,
        role: role,
        invitation_status: :accepted,
        joined_at: Time.current
      )
    end
  end

  def decline!
    update!(status: :declined, declined_at: Time.current)
  end

  def revoke!
    update!(status: :revoked, revoked_at: Time.current)
  end
end
