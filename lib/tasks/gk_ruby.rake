namespace :gk_ruby do
  desc "Provision an organization, owner, public form, and editable draft"
  task provision: :environment do
    required = %w[ORGANIZATION_NAME ORGANIZATION_SLUG ADMIN_NAME ADMIN_EMAIL ADMIN_PASSWORD]
    missing = required.select { |key| ENV[key].blank? }
    abort "Missing required environment variables: #{missing.join(', ')}" if missing.any?

    organization = OrganizationProvisioner.new(
      organization_name: ENV.fetch("ORGANIZATION_NAME"),
      organization_slug: ENV.fetch("ORGANIZATION_SLUG"),
      admin_name: ENV.fetch("ADMIN_NAME"),
      admin_email: ENV.fetch("ADMIN_EMAIL"),
      admin_password: ENV.fetch("ADMIN_PASSWORD")
    ).call

    puts "Provisioned #{organization.name} at /forms/#{organization.slug}"
  end
end
