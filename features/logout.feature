Feature: Logout from an account
    As a logged in user
    In order that no one can access my account
    I want to be able to logout of my account

	@javascript    
    Scenario: Logout while logged in
		Given pending
			# THIS IS NOT WORKING IN THE WEBDRIVER!
        Given I am on /
        And there exists a user named "test" with password "password"
        When I log in as "test" with password "password"
		And I wait 10 seconds
        And I follow "Logout"
		And I wait 10 seconds
        Then I should be on /
        And I should see "Anonymous"
        
	@javascript    
    Scenario: Logout while not logged in
		Given pending
			# THIS IS NOT WORKING IN THE WEBDRIVER!
        Given I am not logged in
        When I go to /logout
        Then I should be on /
        And I should see "Anonymous"



