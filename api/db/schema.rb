# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_19_235500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "expense_payers", force: :cascade do |t|
    t.bigint "amount_minor", null: false
    t.datetime "created_at", null: false
    t.bigint "expense_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["expense_id", "user_id"], name: "index_expense_payers_on_expense_id_and_user_id", unique: true
    t.index ["expense_id"], name: "index_expense_payers_on_expense_id"
    t.index ["user_id"], name: "index_expense_payers_on_user_id"
    t.check_constraint "amount_minor > 0", name: "expense_payers_positive_amount"
  end

  create_table "expense_shares", force: :cascade do |t|
    t.bigint "amount_minor", null: false
    t.datetime "created_at", null: false
    t.bigint "expense_id", null: false
    t.integer "percentage_basis_points"
    t.integer "share_units"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["expense_id", "user_id"], name: "index_expense_shares_on_expense_id_and_user_id", unique: true
    t.index ["expense_id"], name: "index_expense_shares_on_expense_id"
    t.index ["user_id"], name: "index_expense_shares_on_user_id"
    t.check_constraint "amount_minor >= 0", name: "expense_shares_nonnegative_amount"
    t.check_constraint "percentage_basis_points IS NULL OR percentage_basis_points >= 0 AND percentage_basis_points <= 10000", name: "expense_shares_percentage_range"
    t.check_constraint "share_units IS NULL OR share_units > 0", name: "expense_shares_positive_units"
  end

  create_table "expenses", force: :cascade do |t|
    t.bigint "amount_minor", null: false
    t.string "category", default: "general", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.string "currency_code", limit: 3, default: "USD", null: false
    t.datetime "deleted_at"
    t.string "description", null: false
    t.date "expense_date", null: false
    t.bigint "group_id", null: false
    t.text "notes"
    t.string "split_method", default: "equal", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_expenses_on_category"
    t.index ["created_by_id"], name: "index_expenses_on_created_by_id"
    t.index ["deleted_at"], name: "index_expenses_on_deleted_at"
    t.index ["group_id", "expense_date"], name: "index_expenses_on_group_id_and_expense_date"
    t.index ["group_id"], name: "index_expenses_on_group_id"
    t.check_constraint "amount_minor > 0", name: "expenses_positive_amount"
    t.check_constraint "category::text = ANY (ARRAY['general'::character varying, 'food_drink'::character varying, 'groceries'::character varying, 'transportation'::character varying, 'accommodation'::character varying, 'utilities'::character varying, 'entertainment'::character varying, 'shopping'::character varying]::text[])", name: "expenses_category_check"
    t.check_constraint "currency_code::text ~ '^[A-Z]{3}$'::text", name: "expenses_currency_code_format"
    t.check_constraint "split_method::text = ANY (ARRAY['equal'::character varying, 'exact'::character varying, 'percentage'::character varying, 'shares'::character varying]::text[])", name: "expenses_split_method_check"
  end

  create_table "friendships", force: :cascade do |t|
    t.datetime "accepted_at"
    t.bigint "addressee_id", null: false
    t.datetime "blocked_at"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.bigint "requester_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index "LEAST(requester_id, addressee_id), GREATEST(requester_id, addressee_id)", name: "index_friendships_on_user_pair", unique: true
    t.index ["addressee_id"], name: "index_friendships_on_addressee_id"
    t.index ["deleted_at"], name: "index_friendships_on_deleted_at"
    t.index ["requester_id"], name: "index_friendships_on_requester_id"
    t.index ["status"], name: "index_friendships_on_status"
    t.check_constraint "requester_id <> addressee_id", name: "friendships_distinct_users_check"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'accepted'::character varying, 'blocked'::character varying]::text[])", name: "friendships_status_check"
  end

  create_table "group_invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "declined_at"
    t.string "email", null: false
    t.bigint "group_id", null: false
    t.bigint "invited_by_id", null: false
    t.datetime "revoked_at"
    t.string "role", default: "member", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index "group_id, lower((email)::text)", name: "index_pending_group_invitations_on_group_and_email", unique: true, where: "((status)::text = 'pending'::text)"
    t.index ["group_id"], name: "index_group_invitations_on_group_id"
    t.index ["invited_by_id"], name: "index_group_invitations_on_invited_by_id"
    t.index ["status"], name: "index_group_invitations_on_status"
    t.check_constraint "role::text = ANY (ARRAY['admin'::character varying, 'member'::character varying]::text[])", name: "group_invitations_role_check"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'accepted'::character varying, 'declined'::character varying, 'revoked'::character varying]::text[])", name: "group_invitations_status_check"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.string "invitation_status", default: "accepted", null: false
    t.datetime "joined_at"
    t.datetime "removed_at"
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id", "user_id"], name: "index_group_memberships_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["invitation_status"], name: "index_group_memberships_on_invitation_status"
    t.index ["removed_at"], name: "index_group_memberships_on_removed_at"
    t.index ["role"], name: "index_group_memberships_on_role"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
    t.check_constraint "invitation_status::text = ANY (ARRAY['pending'::character varying, 'accepted'::character varying, 'declined'::character varying, 'revoked'::character varying]::text[])", name: "group_memberships_invitation_status_check"
    t.check_constraint "role::text = ANY (ARRAY['owner'::character varying, 'admin'::character varying, 'member'::character varying]::text[])", name: "group_memberships_role_check"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.string "group_type", default: "other", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_groups_on_archived_at"
    t.index ["created_by_id"], name: "index_groups_on_created_by_id"
    t.index ["deleted_at"], name: "index_groups_on_deleted_at"
    t.index ["group_type"], name: "index_groups_on_group_type"
    t.check_constraint "group_type::text = ANY (ARRAY['trip'::character varying, 'household'::character varying, 'partner'::character varying, 'family'::character varying, 'friends'::character varying, 'other'::character varying]::text[])", name: "groups_group_type_check"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "jti", default: -> { "gen_random_uuid()" }, null: false
    t.string "name", null: false
    t.string "profile_status", default: "active", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.check_constraint "profile_status::text = ANY (ARRAY['active'::character varying, 'deactivated'::character varying]::text[])", name: "users_profile_status_check"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "expense_payers", "expenses"
  add_foreign_key "expense_payers", "users"
  add_foreign_key "expense_shares", "expenses"
  add_foreign_key "expense_shares", "users"
  add_foreign_key "expenses", "groups"
  add_foreign_key "expenses", "users", column: "created_by_id"
  add_foreign_key "friendships", "users", column: "addressee_id"
  add_foreign_key "friendships", "users", column: "requester_id"
  add_foreign_key "group_invitations", "groups"
  add_foreign_key "group_invitations", "users", column: "invited_by_id"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "groups", "users", column: "created_by_id"
end
