Feature: Logout from an account
    As a logged in user
    In order that no one can access my account when I'm done
    I want to be able to logout of my account

    Scenario: Logout while logged in
        Given I am on /
        And there exists a user named "test" with password "password"
        When I log in as "test" with password "password"
        And I follow "Logout"
        Then I should be on /
        And I should see "Anonymous"
        
    Scenario: Logout directly to URL while logged in
        Given I am on /
        And there exists a user named "test" with password "password"
        When I log in as "test" with password "password"
        And I go to /logout
        Then I should be on /
        And I should see "Anonymous"
        
    Scenario: Logout while not logged in
        Given I am not logged in
        When I go to /logout
        Then I should be on /
        And I should see "Anonymous"



