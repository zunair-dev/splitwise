require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "creates owner membership for creator" do
    assert_difference "GroupMembership.count", 1 do
      @group = Group.create!(name: "Apartment", group_type: :household, created_by: users(:carol))
    end

    membership = @group.group_memberships.find_by!(user: users(:carol))
    assert membership.owner?
    assert membership.accepted?
  end
end
