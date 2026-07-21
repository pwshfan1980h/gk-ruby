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

ActiveRecord::Schema[8.1].define(version: 2026_07_21_011000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_events", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "auditable_id"
    t.string "auditable_type"
    t.datetime "created_at", null: false
    t.string "ip_digest"
    t.jsonb "metadata", default: {}, null: false
    t.bigint "organization_id", null: false
    t.bigint "user_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_events_on_auditable_type_and_auditable_id"
    t.index ["organization_id", "created_at"], name: "index_audit_events_on_organization_id_and_created_at"
    t.index ["organization_id"], name: "index_audit_events_on_organization_id"
    t.index ["user_id"], name: "index_audit_events_on_user_id"
    t.check_constraint "char_length(action::text) >= 1 AND char_length(action::text) <= 100", name: "audit_events_action_length"
  end

  create_table "form_fields", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "field_key", null: false
    t.integer "field_type", null: false
    t.bigint "form_version_id", null: false
    t.text "help_text"
    t.string "label", null: false
    t.integer "max_length"
    t.jsonb "options", default: [], null: false
    t.string "placeholder"
    t.integer "position", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["form_version_id", "field_key"], name: "index_form_fields_on_form_version_id_and_field_key", unique: true
    t.index ["form_version_id", "position"], name: "index_form_fields_on_form_version_id_and_position"
    t.index ["form_version_id"], name: "index_form_fields_on_form_version_id"
    t.check_constraint "\"position\" >= 0 AND \"position\" <= 29", name: "form_fields_position_range"
    t.check_constraint "field_type >= 0 AND field_type <= 8", name: "form_fields_type_valid"
    t.check_constraint "max_length IS NULL OR max_length >= 1 AND max_length <= 5000", name: "form_fields_max_length_range"
  end

  create_table "form_versions", force: :cascade do |t|
    t.text "confirmation_message"
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.bigint "form_id", null: false
    t.text "intro"
    t.integer "lock_version", default: 0, null: false
    t.bigint "organization_id", null: false
    t.datetime "published_at"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "version_number", null: false
    t.index ["created_by_id"], name: "index_form_versions_on_created_by_id"
    t.index ["form_id", "version_number"], name: "index_form_versions_on_form_id_and_version_number", unique: true
    t.index ["form_id"], name: "index_form_versions_on_form_id"
    t.index ["form_id"], name: "index_form_versions_one_draft", unique: true, where: "(status = 0)"
    t.index ["form_id"], name: "index_form_versions_one_published", unique: true, where: "(status = 1)"
    t.index ["id", "organization_id"], name: "index_form_versions_on_id_and_organization_id", unique: true
    t.index ["organization_id"], name: "index_form_versions_on_organization_id"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2])", name: "form_versions_status_valid"
    t.check_constraint "version_number > 0", name: "form_versions_version_positive"
  end

  create_table "forms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.string "slug", default: "complaint", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "organization_id"], name: "index_forms_on_id_and_organization_id", unique: true
    t.index ["organization_id", "slug"], name: "index_forms_on_organization_id_and_slug", unique: true
    t.index ["organization_id"], name: "index_forms_on_organization_id", unique: true
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.citext "email_address", null: false
    t.datetime "expires_at", null: false
    t.bigint "invited_by_id", null: false
    t.bigint "organization_id", null: false
    t.integer "role", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_invitations_on_expires_at"
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["organization_id", "email_address"], name: "index_invitations_one_pending_per_email", unique: true, where: "(accepted_at IS NULL)"
    t.index ["organization_id"], name: "index_invitations_on_organization_id"
    t.check_constraint "role = ANY (ARRAY[0, 1])", name: "invitations_role_valid"
  end

  create_table "memberships", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "organization_id", null: false
    t.integer "role", default: 1, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_id", "user_id"], name: "index_memberships_on_organization_id_and_user_id", unique: true
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
    t.check_constraint "role = ANY (ARRAY[0, 1])", name: "memberships_role_valid"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "accent_color", default: "#1D4ED8", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "monthly_submission_limit", default: 10000, null: false
    t.string "name", null: false
    t.text "privacy_notice"
    t.integer "retention_days", default: 90, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
    t.check_constraint "accent_color::text ~ '^#[0-9A-Fa-f]{6}$'::text", name: "organizations_accent_color_format"
    t.check_constraint "monthly_submission_limit >= 1 AND monthly_submission_limit <= 100000", name: "organizations_monthly_limit_range"
    t.check_constraint "retention_days >= 1 AND retention_days <= 365", name: "organizations_retention_days_range"
    t.check_constraint "slug::text ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'::text", name: "organizations_slug_format"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "ip_digest"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["expires_at"], name: "index_sessions_on_expires_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "submissions", force: :cascade do |t|
    t.jsonb "answers", default: {}, null: false
    t.datetime "created_at", null: false
    t.bigint "form_version_id", null: false
    t.bigint "organization_id", null: false
    t.string "reference_number", null: false
    t.datetime "retained_until", null: false
    t.integer "status", default: 0, null: false
    t.datetime "submitted_at", null: false
    t.string "submitter_ip_digest"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["form_version_id"], name: "index_submissions_on_form_version_id"
    t.index ["organization_id", "status", "submitted_at"], name: "idx_on_organization_id_status_submitted_at_7d28c790f0"
    t.index ["organization_id", "submitted_at"], name: "index_submissions_on_organization_id_and_submitted_at"
    t.index ["organization_id"], name: "index_submissions_on_organization_id"
    t.index ["reference_number"], name: "index_submissions_on_reference_number", unique: true
    t.index ["retained_until"], name: "index_submissions_on_retained_until"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2])", name: "submissions_status_valid"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.citext "email_address", null: false
    t.datetime "last_sign_in_at"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "audit_events", "organizations"
  add_foreign_key "audit_events", "users"
  add_foreign_key "form_fields", "form_versions"
  add_foreign_key "form_versions", "forms", column: ["form_id", "organization_id"], primary_key: ["id", "organization_id"]
  add_foreign_key "form_versions", "organizations"
  add_foreign_key "form_versions", "users", column: "created_by_id"
  add_foreign_key "forms", "organizations"
  add_foreign_key "invitations", "organizations"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "submissions", "form_versions", column: ["form_version_id", "organization_id"], primary_key: ["id", "organization_id"]
  add_foreign_key "submissions", "organizations"
end
