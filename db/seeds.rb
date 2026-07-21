# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
if Rails.env.development?
  unless Organization.exists?
    OrganizationProvisioner.new(
      organization_name: "Example Community Services",
      organization_slug: "example-community-services",
      admin_name: "Development Administrator",
      admin_email: "admin@example.test",
      admin_password: "Development-Only-Password-1"
    ).call
  end
elsif ENV["ORGANIZATION_NAME"].present?
  OrganizationProvisioner.new(
    organization_name: ENV.fetch("ORGANIZATION_NAME"),
    organization_slug: ENV.fetch("ORGANIZATION_SLUG"),
    admin_name: ENV.fetch("ADMIN_NAME"),
    admin_email: ENV.fetch("ADMIN_EMAIL"),
    admin_password: ENV.fetch("ADMIN_PASSWORD")
  ).call
end
