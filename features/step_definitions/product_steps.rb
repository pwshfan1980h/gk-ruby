Given("{string} has a published complaint form titled {string}") do |organization_name, title|
  organization = Organization.find_or_create_by!(name: organization_name) do |record|
    record.slug = organization_name.parameterize
    record.privacy_notice = "We use your information only to review your complaint."
  end
  @organization = organization
  form = organization.form || organization.create_form!(name: "Complaint form", slug: "complaint")
  next if form.published_version

  version = form.versions.create!(
    organization: organization,
    version_number: 1,
    status: :draft,
    title: title,
    intro: "Tell us what happened and we will review it.",
    confirmation_message: "Thank you. Your complaint has been received."
  )
  version.fields.create!(
    field_type: :long_text,
    field_key: "incident-summary",
    label: "What happened?",
    required: true,
    position: 0,
    max_length: 5_000
  )
  version.fields.create!(
    field_type: :simulated_file,
    field_key: "supporting-document",
    label: "Supporting document",
    required: false,
    position: 1
  )
  version.update!(status: :published, published_at: Time.current)
end

Given("{string} administers {string}") do |administrator_name, organization_name|
  organization = Organization.find_or_create_by!(name: organization_name) do |record|
    record.slug = organization_name.parameterize
  end
  user = User.find_or_create_by!(email_address: "#{administrator_name.parameterize}@example.com") do |record|
    record.name = administrator_name
    record.password = "Correct-Horse-Battery-1"
    record.password_confirmation = "Correct-Horse-Battery-1"
  end
  Membership.find_or_create_by!(organization: organization, user: user) { |membership| membership.role = :owner }
  @administrator = user
end

Given("its draft is titled {string}") do |title|
  organization = @organization
  form = organization.form
  public_version = form.published_version
  draft = form.versions.create!(
    organization: organization,
    version_number: public_version.version_number + 1,
    status: :draft,
    title: title,
    intro: public_version.intro,
    confirmation_message: public_version.confirmation_message,
    created_by: @administrator
  )
  public_version.fields.each do |field|
    draft.fields.create!(field.attributes.slice(
      "field_key", "field_type", "label", "help_text", "placeholder",
      "required", "position", "max_length", "options"
    ))
  end
end

When("I open the public complaint form for {string}") do |organization_name|
  organization = Organization.find_by!(name: organization_name)
  @submission_count = organization.submissions.count
  visit public_form_path(organization_slug: organization.slug)
end

When("I answer {string} with {string}") do |label, answer|
  fill_in label, with: answer
end

When("I submit the complaint") do
  travel 2.seconds do
    click_button "Submit complaint"
  end
end

When("I sign in as {string}") do |administrator_name|
  user = User.find_by!(name: administrator_name)
  visit new_session_path
  fill_in "Email address", with: user.email_address
  fill_in "Password", with: "Correct-Horse-Battery-1"
  click_button "Sign in"
end

When("I publish the complaint form for {string}") do |organization_name|
  organization = Organization.find_by!(name: organization_name)
  visit edit_admin_organization_form_path(organization)
  click_button "Publish saved draft"
end

When("I attempt to open administration for {string}") do |organization_name|
  organization = Organization.find_by!(name: organization_name)
  visit admin_organization_path(organization)
end

Then("I should see that the complaint was received") do
  page.assert_selector("h1", text: "Complaint received")
end

Then("I should receive a complaint reference number") do
  page.assert_text(/GK-[A-F0-9]{12}/)
end

Then("the complaint should be available to {string}") do |organization_name|
  organization = Organization.find_by!(name: organization_name)
  raise "Expected one complaint to be stored" unless organization.submissions.count == @submission_count + 1
end

Then("I should be asked to correct the complaint") do
  page.assert_text("Please correct")
end

Then("no new complaint should be stored") do
  raise "A complaint was stored unexpectedly" unless Submission.count == @submission_count
end

Then("I should be told that file contents are not retained") do
  page.assert_text("its contents are not retained")
end

Then("the public complaint form for {string} should be titled {string}") do |organization_name, title|
  organization = Organization.find_by!(name: organization_name)
  visit public_form_path(organization_slug: organization.slug)
  page.assert_selector("h1", text: title)
end

Then("{string} should still have exactly one public version") do |organization_name|
  count = Organization.find_by!(name: organization_name).form.versions.published.count
  raise "Expected exactly one public version, found #{count}" unless count == 1
end

Then("{string} should have a new editable draft") do |organization_name|
  draft = Organization.find_by!(name: organization_name).form.draft_version
  raise "Expected a new editable draft" unless draft&.editable?
end

Then("access should be denied without showing organization data") do
  raise "Expected a 404 response, received #{page.status_code}" unless page.status_code == 404
  page.assert_no_text("Beta complaints")
end

Then("I should see {string}") do |text|
  page.assert_text(text)
end

Then("I should not see {string}") do |text|
  page.assert_no_text(text)
end
