Feature: Log into an account
    As an existing user
    In order that I be able to store programs and data under my account
    I want to be able to login to my account
    
    Scenario: Login to a valid account
        Given I am on /login
        And there exists a user named "test" with password "password"
        When I fill in the following:
            | name       | test     |
            | password   | password |
        And I press "Log in"
        Then I should see "test"
        And I should see "Logout"
        And I should be on /
        
    Scenario: Login to an invalid account
        Given I am on /login
        And there does not exist a user named "test"
        When I fill in the following:
            | name                 | test     |
            | password             | password |
        And I press "Log in"
        Then I should be on /login
        And I should see "errors"
        And I should see "Name and password combination not found"


    Scenario: Login to an account with wrong password
        Given I am on /login
        And there exists a user named "test" with password "password"
        When I fill in the following:
            | name                 | test     |
            | password             | passwo   |
        And I press "Log in"
        Then I should be on /login
        And I should see "errors"
        And I should see "Name and password combination not found"


