require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email and supports devise password authentication" do
    user = User.create!(
      name: " New User ",
      email: " New.User@Example.COM ",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_equal "new.user@example.com", user.email
    assert_equal "New User", user.name
    assert user.valid_password?("password123")
  end

  test "requires unique email case insensitively" do
    user = User.new(name: "Duplicate", email: "ALICE@example.com", password: "password123")

    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end
end
