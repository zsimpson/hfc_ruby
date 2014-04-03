require 'spec_helper'
require 'user'

describe User do
	it "should allow a friendship" do
		lambda {
			u1 = User.create!( :name=>'test1' )
			u2 = User.create!( :name=>'test2' )
			u1.add_friend_by_id( u2.id )
		}.should change{ Friendship.count }.from(0).to(1)
	end

	it "should not allow a duplicate friendship" do
		u1 = User.create!( :name=>'test1' )
		u2 = User.create!( :name=>'test2' )
		u1.add_friend_by_id( u2.id )
		lambda {
			u1.add_friend_by_id( u2.id )
		}.should raise_error( ActiveRecord::RecordInvalid )
	end

	it "should not allow you to friend yourself" do
		u1 = User.create!( :name=>'test1' )
		u1.should be_valid
		lambda {
			u1.add_friend_by_id( u1.id )
		}.should raise_error( ActiveRecord::RecordInvalid )
	end

	it "should return nothing if you have no friends" do
		u = User.new
		friends_programs = u.get_friends_programs
		friends_programs.should be_empty
	end

	it "should return a friend if you have one even if they don't have any programs" do
		me = User.create!( :name=>'test1' )
		friend = User.create!( :name=>'test2' )
		me.add_friend_by_id( friend.id )
		friends_programs = me.get_friends_programs
		friends_programs.length.should == 1
	end

	it "should return a friend and their programs" do
		me = User.create!( :name=>'test1' )
		friend = User.create!( :name=>'test2' )
		me.add_friend_by_id( friend.id )
		friends_program0 = Program.new_program_and_version( friend.id, "program1", "startcode", "loopcode", nil )
		friends_program1 = Program.new_program_and_version( friend.id, "program2", "startcode", "loopcode", nil )

		friends_programs = me.get_friends_programs
		friends_programs.length.should == 1
		friends_programs[0][:programs].length.should == 2
		friends_programs[0][:programs][0][:program_id].to_i.should == friends_program0.id.to_i
		friends_programs[0][:programs][1][:program_id].to_i.should == friends_program1.id.to_i
	end

	it "should allow a friendship by name" do
		lambda {
			@u1 = User.create!( :name=>'test1' )
			@u2 = User.create!( :name=>'test2' )
			@u1.add_friend_by_name( @u2.name )
		}.should change{ Friendship.count }.from(0).to(1)
		@u1.friends[0].id.should == @u2.id
	end

	it "should exception when adding a friendship by a bad name" do
		lambda {
			@u1 = User.create!( :name=>'test1' )
			@u2 = User.create!( :name=>'test2' )
			@u1.add_friend_by_name( "oinkmcoink" )
		}.should raise_error( ActiveRecord::RecordNotFound )
	end


end
