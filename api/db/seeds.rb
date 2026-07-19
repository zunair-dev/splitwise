if Rails.env.development?
  seed_password = ENV.fetch("SEED_USER_PASSWORD", "password123")
  seed_user = User.find_or_initialize_by(
    email: ENV.fetch("SEED_USER_EMAIL", "demo@zplitwise.local").strip.downcase
  )

  seed_user.assign_attributes(
    name: ENV.fetch("SEED_USER_NAME", "Demo User").strip,
    password: seed_password,
    password_confirmation: seed_password,
    profile_status: :active,
    deleted_at: nil
  )
  seed_user.save!

  puts "Seeded development user: #{seed_user.email}"
else
  puts "Development user seed skipped in #{Rails.env}."
end
