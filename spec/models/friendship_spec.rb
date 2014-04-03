require 'spec_helper'
require 'friendship'

describe Friendship do
	it "should disallow duplicate friendships" do
		lambda {
			@u1 = User.create!( :name=>'test1' )
			@u2 = User.create!( :name=>'test2' )
			Friendship.create!( :user_id=>@u1.id, :friend_id=>@u2.id ) 
			Friendship.create!( :user_id=>@u1.id, :friend_id=>@u2.id ) 
		}.should raise_error( ActiveRecord::RecordInvalid )
	end

	it "should remove a friendship by ids" do
		@u1 = User.create!( :name=>'test1' )
		@u2 = User.create!( :name=>'test2' )
		Friendship.create!( :user_id=>@u1.id, :friend_id=>@u2.id )
		@u1.friends.count.should == 1
		Friendship.remove_by_ids( @u1.id, @u2.id )
		@u1.friends.count.should == 0
	end

end
