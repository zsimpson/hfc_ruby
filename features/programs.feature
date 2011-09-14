Feature: View programs and friends
    As an existing user
    In order that I be able my and my friends' programs
    I want to be able to see my programs and add friends
    
	@javascript
    Scenario: Anonymous user should see login
		Given I am not logged in
		When I follow "Programs"
		Then I should see "Login to see your and your friends' programs"

	@javascript
    Scenario: New user should see no programs and no friends
		Given I am logged in as test
		When I follow "Programs"
		Then I should see "You have no programs yet"
		And I should see "You have no friends yet"

	@javascript
    Scenario: Existing user should their own programs
		Given I am logged in as test
		And user "test" has a program called "hello_world"
		When I follow "Programs"
		Then I should see "hello_world"

	@javascript
    Scenario: Existing user should be able to add friends
		Given I am logged in as test
		And there exists a user named "zack" with password "password"
		When I follow "Programs"
		And I fill in "programFriendAddName" with "zack"
		And I press "Add friend"
		Then inside "#friendsList" I should see "zack"

	@javascript
    Scenario: Existing user should be able to see their friends' programs
		Given pending

	@javascript
    Scenario: Existing user should be able to delete their own program
		Given pending

	@javascript
    Scenario: Existing user should be able to delete a friend
		Given pending

	@javascript
    Scenario: Existing user should be able to go to their own program
		Given pending

	@javascript
    Scenario: Existing user should be able to go to a friend's program
		Given pending

	@javascript
    Scenario: Existing user should not be able to themselves as a friend
		Given pending

	@javascript
    Scenario: Existing user should not be able to add non-existing person as a friend
		Given pending

	@javascript
    Scenario: Existing user should not be able to add same friend twice
		Given pending

