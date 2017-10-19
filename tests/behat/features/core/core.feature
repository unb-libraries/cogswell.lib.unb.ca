# Basic functionality testing.
# Ref : phase2/behat-suite
# http://behat-drupal-extension.readthedocs.io/en/3.1/drupalapi.htm

@api
Feature: Core
  In order to know the website is running
  As a website user
  I need to be able to view the site title and login

  @api
    Scenario: Run cron
      Given I am logged in as a user with the "administrator" role
      When I run cron
      And am on "admin/reports/dblog"
      Then I should see the link "Cron run completed"

    Scenario: Create users
      Given users:
      | name     | mail            | status |
      | Joe User | joe@example.com | 1      |
      And I am logged in as a user with the "administrator" role
      When I visit "admin/people"
      Then I should see the link "Joe User"

    Scenario: Login as a user created during this scenario
      Given users:
      | name      | status |
      | Test user |      1 |
      When I am logged in as "Test user"
      And I visit "user/login"
      Then I should see "Test user"

    Scenario: Create a term
      Given I am logged in as a user with the "administrator" role
      When I am viewing a "tags" term with the name "My tag"
      Then I should see the heading "My tag"

    Scenario: Create many terms
      Given "tags" terms:
      | name    |
      | Tag one |
      | Tag two |
      And I am logged in as a user with the "administrator" role
      When I go to "admin/structure/taxonomy/manage/tags/overview"
      Then I should see "Tag one"
      And I should see "Tag two"

    Scenario: Visit Home
      When I click "Home"
      Then I should see "Welcome"

    Scenario: Visit Preface
      When I click "Preface & Acknowledgements"
      Then I should see "Massey-Lévesque"

    Scenario: Visit Bio
      When I click "Biography"
      Then I should see the link "Ancestry"

    Scenario: Visit Poetry
      When I click "Poetry & Poetics"
      Then I should see the link "Cogswell Poem Titles Published by Borealis"

    Scenario: Visit Correspondence
      When I click "Correspondence"
      Then I should see the link "Next: Letters"

    Scenario: Visit Bibliography
      When I click "Bibliography"
      Then I should see the link "Essays, Chapters, Introductions, etc."

    Scenario: Visit Works
      When I click "Works Cited"
      Then I should see "Geddes. Toronto: Oxford UP, 1969. 10."

    Scenario: Visit Contact
      When I click "Contact"
      Then I should see the button "Send message"

    Scenario: Visit Admin Login
      When I click "Admin Login"
      Then I should see the button "Log in"
