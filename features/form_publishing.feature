Feature: Publishing a complaint form
  Administrators can change a private draft without changing the public form.
  Publishing replaces the public version atomically and preserves history.

  Background:
    Given "Avery Admin" administers "Acme Services"
    And "Acme Services" has a published complaint form titled "Original complaint form"
    And its draft is titled "Revised complaint form"

  Rule: Saving and publishing are separate decisions

    Scenario: The draft stays private until publication
      When I open the public complaint form for "Acme Services"
      Then I should see "Original complaint form"
      And I should not see "Revised complaint form"

    Scenario: Publish the saved draft
      When I sign in as "Avery Admin"
      And I publish the complaint form for "Acme Services"
      Then the public complaint form for "Acme Services" should be titled "Revised complaint form"
      And "Acme Services" should still have exactly one public version
      And "Acme Services" should have a new editable draft
