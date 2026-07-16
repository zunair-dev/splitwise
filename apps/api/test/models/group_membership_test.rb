require "test_helper"

class GroupMembershipTest < ActiveSupport::TestCase
  test "prevents duplicate members in a group" do
    membership = GroupMembership.new(group: groups(:trip), user: users(:alice), role: :member)

    assert_not membership.valid?
    assert_includes membership.errors[:user_id], "has already been taken"
  end

  test "remove marks removed timestamp" do
    membership = group_memberships(:trip_member)

    membership.remove!

    assert membership.removed?
  end
end
