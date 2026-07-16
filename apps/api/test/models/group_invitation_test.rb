require "test_helper"

class GroupInvitationTest < ActiveSupport::TestCase
  test "normalizes invitation email" do
    invitation = GroupInvitation.create!(
      group: groups(:trip),
      invited_by: users(:alice),
      email: " NewInvite@Example.COM ",
      role: :member
    )

    assert_equal "newinvite@example.com", invitation.email
  end

  test "accept creates accepted membership" do
    invitation = group_invitations(:trip_pending)

    assert_difference "GroupMembership.count", 1 do
      invitation.accept!(users(:carol))
    end

    assert invitation.accepted?
    assert groups(:trip).group_memberships.exists?(user: users(:carol), invitation_status: :accepted)
  end
end
