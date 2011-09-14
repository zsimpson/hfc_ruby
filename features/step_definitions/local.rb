Given /^there exists a user named "([^"]*)" with password "([^"]*)"$/ do |name,password|
  u = User.new( :name=>name, :password=>password )
  u.save!
end

Then /^there should exist a user named "([^"]*)"$/ do |name|
  User.find_by_name( name )
end

Then /^there should not exist a user named "([^"]*)"$/ do |name|
  !User.find_by_name( name )
end

Given /^there does not exist a user named "([^"]*)"$/ do |name|
  u = User.find_by_name( name )
  if u
    u.destroy()
  end
end

When /^I log in as "([^"]*)" with password "([^"]*)"$/ do |name,password|
  visit "/login"
  fill_in( "name", :with=>name )
  fill_in( "password", :with=>password )
  click_button("Log in")
end

Given /^I am not logged in$/ do
  visit "/logout"
end

Given /^I am logged in as test$/ do
  u = User.new( :name=>"test", :password=>"password", :password_verify=>"password" )
  u.save!
  visit "/login"
  fill_in( "Name", :with=>"test" )
  fill_in( "Password", :with=>"password" )
  click_button("Log in")
end

#########################################################

When /^I close all file tabs$/ do
  all( ".closeIcon" ).each { |button| button.click }
end

Then /^inside "([^"]*)" I should see "([^"]*)"$/ do |area,value|
  find(area).should have_content( value )
end

Then /^inside field "([^"]*)" I should see "([^"]*)"$/ do |area,val|
  find(area).value.should have_content( val )
end

Then /^inside "([^"]*)" I should see nothing$/ do |area|
  find(area).should have_content( "" )
end

When /^I click on div "([^"]*)"$/ do |area|
  find(area).click()
end

Then /^"([^"]*)" should be visible$/ do |area|
  assert page.find( area ).visible? == true
end

Then /^"([^"]*)" should not be visible$/ do |area|
  assert page.find( area ).visible? != true
end

When /^I click on all the delete friends buttons$/ do
  all( ".friendDeleteButton" ).each { |button| button.click }
end

Given /^user "([^"]*)" has a program called "([^"]*)"/ do |name,program|
  u = User.find_by_name( name )
  p = Program.new
  p.user_id = u.id
  p.name = program
  p.save!
end

Then /^"([^\"]*)" should be disabled$/ do |id|
  find(id)['disabled'].should == "true"
end

Given /^there exists a post "([^"]*)" from "([^"]*)"$/ do |post, name|
  u = User.find_by_name( name )
  p = Post.new
  p.user_id = u.id
  p.content = post
  p.save!
end

When /^I fill in the active code area with "([^"]*)"$/ do |value|
	 evaluate_script "codeSetActiveText('"+value+"')"
end

Then /^the active code area should contain "([^"]*)"$/ do |value|
	a = evaluate_script "codeGetActiveText()"
	assert a.should have_content(value)
end

Then /^I wait (.*) second(s)?$/ do |secs,plural|
	sleep( secs.to_i )
end

When /^I execute "([^"]*)"/ do |name|
	evaluate_script "codeExecuteByName('"+name+"')"
end

