require 'spec_helper'
require 'program'

describe Program do

	it "should normalize names" do
		@me = User.create!( :name=>"me" )
		@p = Program.new_program_and_version( @me.id, "test 1 (*& ", "start1", "loop1", nil )
		@p.name.should == "test_1__"
	end
	
	it "should disallow duplicate names" do
		@me = User.create!( :name=>"me" )
		@p0 = Program.new_program_and_version( @me.id, "test", "start1", "loop1", nil )
		lambda {
			@p1 = Program.new_program_and_version( @me.id, "test", "start2", "loop2", nil )
		}.should raise_error( ActiveRecord::RecordInvalid )
	end

	describe "with one version" do
		before(:each) do
			@me = User.create!( :name=>"me" )
			@p = Program.new_program_and_version( @me.id, "test1", "start1", "loop1", nil )
		end
	 
		it "should be able create a new version" do
			# ALL of the various counts should be 1
			Program.count.should == 1
			ProgramVersion.count.should == 1
			@p.program_versions.count.should == 1
			@p.version_get_count.should == 1
			@p.version_get_all.length.should == 1
		end		

		it "should be able create a second version by the same user" do
			@p.new_version( "start2", "loop2", @me.id, nil )

			# ALL of the version counts should be 2
			Program.count.should == 1
			ProgramVersion.count.should == 2
			@p.program_versions.count.should == 2
			@p.version_get_count.should == 2
			@p.version_get_all.length.should == 2

			vers = @p.version_get_all
			vers[0].start_code.should == "start1"
			vers[0].loop_code.should == "loop1"
			vers[1].start_code.should == "start2"
			vers[1].loop_code.should == "loop2"
			vers[1].user_id.should == @me.id
		end
	
		it "should be able to get the name of the creator of a program" do
			@p.user.name.should == @me.name
		end

		it "should be able to create a version posted by a different user" do
			someone_else = User.create!( :name=>"someone" )
			@p.new_version( "start2", "loop2", someone_else.id, nil )
			@p.version_get_all.length.should == 2
			
		end
	end

	describe "with multiple versions" do
		before(:each) do
			me = User.create!( :name=>"me" )
			someone_else = User.create!( :name=>"someone" )
			@p = Program.new_program_and_version( me.id, "test1", "start1", "loop1", nil )
			@p.new_version( "start2", "loop2", someone_else.id, nil )
		end
	
		it "should clamp the version number when fetching a version" do
			# Fetching good version		
			record, version, version_count = @p.version_get( 0 )
			record.start_code.should == "start1"
			version.should == 0
			version_count.should == 2
	
			# Fetching good version		
			record, version, version_count = @p.version_get( 1 )
			record.start_code.should == "start2"
			version.should == 1
			version_count.should == 2
	
			# Fetching bad version, should clamp		
			record, version, version_count = @p.version_get( 2 )
			record.start_code.should == "start2"
			version.should == 1
			version_count.should == 2
		end
	
		it "should return the latest version if asked for -1" do
			record, version, version_count = @p.version_get( -1 )
			record.start_code.should == "start2"
			version.should == 1
			version_count.should == 2
		end
	end

	describe "with many versions" do
		before(:each) do
			@u0 = User.create!( :name=>"u0" )
			@u1 = User.create!( :name=>"u1" )
			@u2 = User.create!( :name=>"u2" )
			@p0 = Program.new_program_and_version( @u0.id, "test0", "start0", "loop0", nil )
			@p1 = Program.new_program_and_version( @u1.id, "test1", "start1", "loop1", nil )
			@p2 = Program.new_program_and_version( @u2.id, "test2", "start2", "loop2", nil )
		end
		
		it "should be able to find the newest programs in sorted order" do
			new_list = Program.version_all_newest( 2 )
			new_list.length.should == 2
			new_list[0].id.should == @p2.id
			new_list[1].id.should == @p1.id
			new_list[0].user.name.should == @u2.name
			new_list[1].user.name.should == @u1.name
		end

		it "should be able to find recent edits in sorted order" do
			@p0.new_version( "start0-1", "loop0-1", @u0.id, nil )
			recent_list = Program.version_all_recent_edits( 2 )
			recent_list.length.should == 2
			recent_list[0].id.should == @p0.id
			recent_list[1].id.should == @p2.id
			recent_list[0].user.name.should == "u0"
			recent_list[0].versioned_at.should_not be_empty
			
		end

	end
	

end
