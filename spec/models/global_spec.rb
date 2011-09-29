require 'spec_helper'
require 'global'

describe Global do

	it "should disallow duplicate names" do
		@me = User.create!( :name=>"me" )
		@g0 = Global.locate_or_create( @me.id, "$test1" )
		lambda {
			@g1 = Global.create!( :user_id=>@me.id, :name=>"$test1" )
		}.should raise_error( ActiveRecord::RecordInvalid )
	end

	describe "with one version" do
		before(:each) do
			@me = User.create!( :name=>"me" )
			@g = Global.locate_or_create( @me.id, "$global1" )
		end
	 
		it "should be able create a new global" do
			# ALL of the various counts should be 1
			Global.count.should == 1
			@g.version_get_count.should == 0
			@g.version_get_all.length.should == 0
		end		

		it "should be able create a first version" do
			@g.new_version( "somecode", @me.id )

			# ALL of the version counts should be 1
			Global.count.should == 1
			GlobalVersion.count.should == 1
			@g.global_versions.count.should == 1
			@g.version_get_count.should == 1
			@g.version_get_all.length.should == 1

			vers = @g.version_get_all
			vers[0].code.should == "somecode"
		end
		
		it "should clean up the function names, storing only the function blocks" do
			@g.new_version( "$global1 = function(x) {\n//some code\n}", @me.id )
			record, version, length = @g.version_get( -1 )
			record.code.should == "function(x) {\n//some code\n}"
		end
	end

	describe "with multiple versions" do
		before(:each) do
			@me = User.create!( :name=>"me" )
			@someone_else = User.create!( :name=>"someone" )
			@g = Global.locate_or_create( @me.id, "$global2" )
			@g.new_version( "somecode1", @me.id )
			@g.new_version( "somecode2", @me.id )
		end
	
		it "should clamp the version number when fetching a version" do
			# Fetching good version		
			record, version, version_count = @g.version_get( 0 )
			record.code.should == "somecode1"
			version.should == 0
			version_count.should == 2
	
			# Fetching good version		
			record, version, version_count = @g.version_get( 1 )
			record.code.should == "somecode2"
			version.should == 1
			version_count.should == 2
	
			# Fetching bad version, should clamp		
			record, version, version_count = @g.version_get( 2 )
			record.code.should == "somecode2"
			version.should == 1
			version_count.should == 2
		end
	
		it "should return the latest version if asked for -1" do
			record, version, version_count = @g.version_get( -1 )
			record.code.should == "somecode2"
			version.should == 1
			version_count.should == 2
		end
	end



end
