Feature: Edit, Save code
    As an user
    In order that I be able use my programs
    I want to be able to CRUD my programs
    
	@javascript
    Scenario: Anonymous user should be able to New but not to save and be able to login without losing their work
		Given I am not logged in
		And there exists a user named "zack" with password "password"
		When I follow "Code"
		Then I should see "Login to save"
		When I press "New"
		And I fill in the main code areas with "start1" and "loop1"
		And I click on div "#codeLoginToSaveLink"
        And I fill in the following:
            | name       | zack     |
            | password   | password |
        And I press "Log in"
		Then I should be on /
		When I follow "Code"
		Then the main code areas should contain "start1" and "loop1"

	@javascript
    Scenario: Existing user should be able to New and when they save they should see a save as box and when they give it sa naem it should appear in programs
		Given I am logged in as test
		When I follow "Code"
		Then I should not see "Login to save"
		When I press "New"
		And I fill in the main code areas with "start1" and "loop1"
		And I press "Save"
		Then "#codeSaveAsDialog" should be visible
		When I fill in "codeSaveAsName" with "test1"
		And I press "Save"
		When I follow "Programs"
		Then I should see "test1"
		When I click on div "#load-program-test-test1"
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
		Then "#codeSaveAsDialog" should be visible
		When I fill in "codeSaveAsName" with "test1"
		And I press "Save"
		When I follow "Programs"
		Then I should see "test1"
		When I click on div "#load-program-test-test1"
		Then I should see "start1"
		And I should see "loop1"

	@javascript
    Scenario: Existing user should be able to Save existing program and save as box should not appear
		Given I am logged in as test
		And user "test" has a program called "test1"
		When I follow "Programs"
		Then I should see "test1"
		When I click on div "#load-program-test-test1"
		Then I should see "this is start code"
		And I should see "this is loop code"
		When I fill in the main code areas with "start123" and "loop123"
		And I press "Save"
		Then "#codeSaveAsDialog" should not be visible
		When I follow "Programs"
		Then I should see "test1"
		When I click on div "#load-program-test-test1"
		Then I should see "start123"
		And I should see "loop123"

	@javascript
    Scenario: Existing user should be able to Save As existing program and save as box should appear
		Given I am logged in as test
		And user "test" has a program called "test1"
		When I follow "Programs"
		Then I should see "test1"
		When I click on div "#load-program-test-test1"
		Then I should see "this is start code"
		And I should see "this is loop code"
		When I fill in the main code areas with "start123" and "loop123"
		And I press "Save As..."
		Then "#codeSaveAsDialog" should be visible
		When I fill in "codeSaveAsName" with "test2"
		And I press "Save"
		When I follow "Programs"
		Then I should see "test1"
		And I should see "test2"
		When I click on div "#load-program-test-test1"
		Then I should see "this is loop code"
		And I should see "this is start code"
		When I follow "Programs"
		When I click on div "#load-program-test-test2"
		Then I should see "start123"
		And I should see "loop123"

	# @TODO: Versioning