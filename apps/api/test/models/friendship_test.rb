require "test_helper"

class FriendshipTest < ActiveSupport::TestCase
  test "does not allow a user to friend themselves" do
    friendship = Friendship.new(requester: users(:alice), addressee: users(:alice))

    assert_not friendship.valid?
    assert_includes friendship.errors[:addressee], "must be different from requester"
  end

  test "does not allow duplicate friendship pairs in reverse order" do
    friendship = Friendship.new(requester: users(:bob), addressee: users(:alice))

    assert_not friendship.valid?
    assert_includes friendship.errors[:base], "friendship already exists for these users"
  end

  test "accept records accepted timestamp" do
    friendship = Friendship.create!(requester: users(:alice), addressee: users(:carol))

    friendship.accept!

    assert friendship.accepted?
    assert_not_nil friendship.accepted_at
  end
end
