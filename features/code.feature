Feature: Edit, Save code
    As an user
    In order that I be able use my programs
    I want to be able to CRUD my programs
	
	@javascript
    Scenario: Logged in user should remember what program was up with a cookie
		Given I am logged in as test
		And user "test" has a program called "test1"
		When I follow "Code"
		And I press "Load..."
		And I click on div "load-program-test-test1"
		And I wait 2 seconds
		Then I should see "this is start code"
		And I should see "this is loop code"
		When I go to /
		And I wait 2 seconds
		Then I should see "this is start code"
		And I should see "this is loop code"
    
	@javascript
    Scenario: Anonymous user should be able to New but not to save and be able to login without losing their work
		Given I am not logged in
		And there exists a user named "zack" with password "password"
		When I follow "Code"
		Then I should see "Login to save"
		When I press "New"
		And I fill in the main code areas with "start1" and "loop1"
		And I click on div "codeLoginToSaveLink"
        And I fill in the following:
            | name       | zack     |
            | password   | password |
        And I press "Log in"
		Then I should be on /
		Then the main code areas should contain "start1" and "loop1"

	@javascript
    Scenario: Existing user should be able to New and when they save they should see a save as box and when they give it a name it should appear in programs
		Given I am logged in as test
		When I follow "Code"
		Then I should not see "Login to save"
		When I press "New"
		And I fill in the main code areas with "start1" and "loop1"
		And I press "Save"
		Then "codeSaveAsControlPanel" should be visible
		When I fill in "codeSaveAsName" with "test1"
		And I press "Save"
		When I press "Load..."
		Then I should see "test1"
		When I click on div "load-program-test-test1"
		And I wait 2 seconds
		Then I should see "start1"
		And I should see "loop1"

	@javascript
    Scenario: Existing user should be able to Save as unnamed program and save as box should appear
		Given I am logged in as test
		When I follow "Code"
		Then I should not see "Login to save"
		When I press "New"
		And I fill in the main code areas with "start1" and "loop1"
		And I press "Save As..."
		Then "codeSaveAsControlPanel" should be visible
		When I fill in "codeSaveAsName" with "test1"
		And I press "Save"
		When I follow "Code"
		And I press "Load..."
		Then I should see "test1"
		When I click on div "load-program-test-test1"
		And I wait 2 seconds
		Then I should see "start1"
		And I should see "loop1"

	@javascript
    Scenario: Existing user should be able to Save existing program and save as box should not appear
		Given I am logged in as test
		And user "test" has a program called "test1"
		When I follow "Code"
		And I press "Load..."
		Then I should see "test1"
		When I click on div "load-program-test-test1"
		And I wait 2 seconds
		Then I should see "this is start code"
		And I should see "this is loop code"
		When I fill in the main code areas with "start123" and "loop123"
		And I press "Save"
		Then "codeSaveAsControlPanel" should not be visible
		When I press "Load..."
		Then I should see "test1"
		When I click on div "load-program-test-test1"
		And I wait 2 seconds
		Then I should see "start123"
		And I should see "loop123"

	@javascript
    Scenario: Existing user should be able to Save As existing program and save as box should appear
		Given I am logged in as test
		And user "test" has a program called "test1"
		When I follow "Code"
		And I press "Load..."
		Then I should see "test1"	
		When I click on div "load-program-test-test1"
		And I wait 2 seconds
		Then I should see "this is start code"
		And I should see "this is loop code"
		When I fill in the main code areas with "start123" and "loop123"
		And I press "Save As..."
		Then "codeSaveAsControlPanel" should be visible
		When I fill in "codeSaveAsName" with "test2"
		And I press "Save"
		And I wait 1 second
		When I press "Load..."
		Then I should see "test1"
		And I should see "test2"
		When I click on div "load-program-test-test1"
		And I wait 2 seconds
		Then I should see "this is loop code"
		And I should see "this is start code"
		When I press "Load..."
		When I click on div "load-program-test-test2"
		And I wait 2 seconds
		Then I should see "start123"
		And I should see "loop123"
		
	@javascript
    Scenario: Existing user should be able to press save after new
		Given I am logged in as test
		When I follow "Code"
		When I press "New"
		And I fill in the main code areas with "start1" and "loop1"
		And I press "Save"
		Then "codeSaveAsControlPanel" should be visible
		When I fill in "codeSaveAsName" with "test1"
		And I press "Save"
		And I fill in the main code areas with "start2" and "loop2"
		And I wait 1 second
		And I press "Save"
		And I wait 1 second
		When I press "New"
		Then the main code areas should contain "" and ""
		When I press "Load..."
		Then I should see "test1"
		When I click on div "load-program-test-test1"
		And I wait 2 seconds
		Then I should see "start2"
		And I should see "loop2"
		
	@javascript
    Scenario: Should be able to go back to previous versions
		Given I am logged in as test
		When I follow "Code"
		When I press "New"
		And I fill in the main code areas with "start1" and "loop1"
		And I press "Save"
		Then "codeSaveAsControlPanel" should be visible
		When I fill in "codeSaveAsName" with "test1"
		And I press "Save"
		Then I should see "1 of 1"
		And I fill in the main code areas with "start2" and "loop2"
		And I press "Save"
		And I wait 1 second
		Then I should see "2 of 2"
		When I press "Previous"
		And I wait 1 second
		Then I should see "1 of 2"
		And the main code areas should contain "start1" and "loop1"
		When I press "Next"
		And I wait 1 second
		Then I should see "2 of 2"
		And the main code areas should contain "start2" and "loop2"

	@javascript
    Scenario: Save as of someone else's program should show you as the author
		Given I am logged in as test
		And there exists a user named "zack" with password "password"
		And user "zack" has a program called "hello_world"
		When I follow "Code"
		And I press "Load..."
		And I click on div "load-program-zack-hello_world"
		And I wait 2 seconds
		And I press "Save As..."
		And I fill in "codeSaveAsName" with "my_version"
		And I press "Save"
		Then I should see "my_version by test"


# @TODO: More test of the versioning.  I know there's some problem the first time you press prev is goes back to the first on so test with a few more
# @TODO: Test the globals and their versioning
# @TODO: Test that the How to embed link brings up a good link
# @TODO: Test that when you load the URL changes to "/run/id"






