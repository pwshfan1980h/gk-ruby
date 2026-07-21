@allow-rescue
Feature: Organization data isolation
  An administrator can access only organizations where they have an active membership.

  Scenario: Attempt to open another organization's administration
    Given "Avery Admin" administers "Acme Services"
    And "Beta Services" has a published complaint form titled "Beta complaints"
    When I sign in as "Avery Admin"
    And I attempt to open administration for "Beta Services"
    Then access should be denied without showing organization data
