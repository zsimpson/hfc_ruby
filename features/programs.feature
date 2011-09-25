Feature: View programs and friends
    As an existing user
    In order that I be able my and my friends' programs
    I want to be able to see my programs and add friends
    
	@javascript
    Scenario: Anonymous user should see login to save
		Given I am not logged in
		When I follow "Code"
		And I press "Load..."
		Then I should see "Login to see your programs"
		And I should see "Login to see your friends"

	@javascript
    Scenario: New user should see no programs and no friends
		Given I am logged in as test
		When I follow "Code"
		And I press "Load..."
		Then I should see "You have no programs yet"
		And I should see "You have no friends yet"

	@javascript
    Scenario: Existing user should their own programs
		Given I am logged in as test
		And user "test" has a program called "hello_world"
		When I follow "Code"
		And I press "Load..."
		Then I should see "hello_world"

	@javascript
    Scenario: Existing user should be able to add friends
		Given I am logged in as test
		And there exists a user named "zack" with password "password"
		When I follow "Code"
		And I press "Load..."
		And I fill in "codeFriendAddName" with "zack"
		And I press "Add friend"
		Then inside div "friendsList" I should see "zack"

	@javascript
    Scenario: Existing user should be able to see their friends' programs
		Given I am logged in as test
		And there exists a user named "zack" with password "password"
		And user "zack" has a program called "hello_world"
		When I follow "Code"
		And I press "Load..."
		And I fill in "codeFriendAddName" with "zack"
		And I press "Add friend"
		Then inside div "friendsList" I should see "zack"
		And inside div "friendsList" I should see "hello_world"

	@javascript
    Scenario: Existing user should not be able to add themselves as a friend
		Given I am logged in as test
		When I follow "Code"
		And I press "Load..."
		And I fill in "codeFriendAddName" with "test"
		And I press "Add friend"
		Then inside div "friendsList" I should not see "test"
		And inside div "codeProgramsErrors" I should see "trying to add self as friend"

	@javascript
    Scenario: Existing user should not be able to add non-existing person as a friend
		Given I am logged in as test
		When I follow "Code"
		And I press "Load..."
		And I fill in "codeFriendAddName" with "oinkoink"
		And I press "Add friend"
		Then inside div "friendsList" I should not see "oinkoink"
		And inside div "codeProgramsErrors" I should see "Friend not found"

	@javascript
    Scenario: Existing user should not be able to add same friend twice
		Given I am logged in as test
		And there exists a user named "zack" with password "password"
		When I follow "Code"
		And I press "Load..."
		And I fill in "codeFriendAddName" with "zack"
		And I press "Add friend"
		And I wait 1 second
		Then inside div "friendsList" I should see "zack"
		And I fill in "codeFriendAddName" with "zack"
		And I press "Add friend"
		And I wait 1 second
		And inside div "codeProgramsErrors" I should see "duplicate"

	@javascript
    Scenario: Existing user should be able to delete their own program
		Given I am logged in as test
		And user "test" has a program called "hello_world"
		When I follow "Code"
		And I press "Load..."
		Then inside div "programsList" I should see "hello_world"
		When I click on div "delete-program-test-hello_world"
		And I press the alert ok button
		And I wait 1 second
		And inside div "programsList" I should not see "hello_world"

	@javascript
    Scenario: Existing user should be able to delete a friend
		Given I am logged in as test
		And there exists a user named "zack" with password "password"
		When I follow "Code"
		And I press "Load..."
		And I fill in "codeFriendAddName" with "zack"
		And I press "Add friend"
		Then inside div "friendsList" I should see "zack"
		When I click on div "delete-friend-zack"
		And I press the alert ok button
		And I wait 1 second
		Then inside div "friendsList" I should not see "zack"

	@javascript
    Scenario: Existing user should be able to go to their own program
		Given pending

	@javascript
    Scenario: Existing user should be able to go to a friend's program
		Given pending






		
		