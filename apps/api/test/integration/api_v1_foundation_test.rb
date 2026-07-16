require "test_helper"

class ApiV1FoundationTest < ActionDispatch::IntegrationTest
  test "creates a user account and returns profile payload" do
    post api_v1_users_path, params: {
      user: {
        name: "Dana Ali",
        email: "Dana@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }, as: :json

    assert_response :created
    assert_equal "dana@example.com", json_response.dig("user", "email")
  end

  test "shows and updates current profile using temporary user header" do
    patch api_v1_profile_path,
      params: { user: { name: "Alice Updated" } },
      headers: auth_headers(users(:alice)),
      as: :json

    assert_response :success
    assert_equal "Alice Updated", json_response.dig("user", "name")
  end

  test "creates and accepts friendship" do
    post api_v1_friendships_path,
      params: { friendship: { email: users(:carol).email } },
      headers: auth_headers(users(:alice)),
      as: :json

    assert_response :created
    friendship_id = json_response.dig("friendship", "id")

    patch accept_api_v1_friendship_path(friendship_id),
      headers: auth_headers(users(:carol)),
      as: :json

    assert_response :success
    assert_equal "accepted", json_response.dig("friendship", "status")
  end

  test "creates group with owner membership" do
    post api_v1_groups_path,
      params: { group: { name: "House", group_type: "household", description: "Shared home costs" } },
      headers: auth_headers(users(:alice)),
      as: :json

    assert_response :created
    group = Group.find(json_response.dig("group", "id"))
    assert group.group_memberships.exists?(user: users(:alice), role: :owner)
  end

  test "owner can add and remove group member" do
    post api_v1_group_memberships_path(groups(:trip)),
      params: { membership: { user_id: users(:carol).id, role: "member" } },
      headers: auth_headers(users(:alice)),
      as: :json

    assert_response :created
    membership_id = json_response.dig("membership", "id")

    delete api_v1_membership_path(membership_id),
      headers: auth_headers(users(:alice)),
      as: :json

    assert_response :success
    assert_not_nil json_response.dig("membership", "removed_at")
  end

  test "owner can create and revoke pending group invitation" do
    post api_v1_group_invitations_path(groups(:trip)),
      params: { invitation: { email: "friend@example.com", role: "member" } },
      headers: auth_headers(users(:alice)),
      as: :json

    assert_response :created
    invitation_id = json_response.dig("invitation", "id")
    assert_equal "pending", json_response.dig("invitation", "status")

    patch revoke_api_v1_invitation_path(invitation_id),
      headers: auth_headers(users(:alice)),
      as: :json

    assert_response :success
    assert_equal "revoked", json_response.dig("invitation", "status")
  end

  private

  def auth_headers(user)
    { "X-User-Id" => user.id.to_s }
  end
end
