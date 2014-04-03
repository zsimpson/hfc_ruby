Feature: Create an account
    As a new user
    In order that I be able to store programs and data under my account
    I want to be able to create an account
    
    Scenario: Create a valid account
        Given I am on /users/create_account
        When I fill in the following:
            | name                 | test     |
            | password             | password |
            | password_verify      | password |
        And I press "Create account"
        Then I should be on /
        And there should exist a user named "test"
        And I should see "test"
        And I should see "Logout"
        
    Scenario: Create an invalid account due to mismatching passwords
        Given I am on /users/create_account
        When I fill in the following:
            | name                 | test     |
            | password             | password |
            | password_verify      | crap     |
        And I press "Create account"
        Then I should be on /users/create_account
        And I should see "errors"
        And I should see "Passwords don't match"
        And there should not exist a user named "test"

    Scenario: Create an invalid account due to non-unique name
        Given I am on /users/create_account
        And there exists a user named "test" with password "password"
        When I fill in the following:
            | name                 | test     |
            | password             | password |
            | password_verify      | password |
        And I press "Create account"
        Then I should be on /users/create_account
        And I should see "errors"
        And I should see "Name already taken"
        And there should not exist a user named "test"

