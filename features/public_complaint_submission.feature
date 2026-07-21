Feature: Public complaint submission
  A member of the public can submit a complaint without creating an account.
  The organization receives validated data from the exact form version the person saw.

  Background:
    Given "Acme Services" has a published complaint form titled "Tell us what happened"

  Rule: A valid complaint receives a reference

    Scenario: Submit the required complaint details
      When I open the public complaint form for "Acme Services"
      And I answer "What happened?" with "A delivery did not arrive."
      And I submit the complaint
      Then I should see that the complaint was received
      And I should receive a complaint reference number
      And the complaint should be available to "Acme Services"

  Rule: Required answers are enforced without losing the form

    Scenario: Omit a required answer
      When I open the public complaint form for "Acme Services"
      And I submit the complaint
      Then I should be asked to correct the complaint
      And no new complaint should be stored

  Rule: Simulated attachment behavior is honest

    Scenario: View the simulated attachment field
      When I open the public complaint form for "Acme Services"
      Then I should be told that file contents are not retained
