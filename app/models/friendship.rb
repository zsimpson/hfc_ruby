class Friendship < ActiveRecord::Base
	belongs_to :user
	belongs_to :friend, :class_name => 'User'
	
	validates_uniqueness_of :friend_id, :scope=>:user_id, :message=>"Duplicate friend"
	validate :disallow_self_friending
	
	def disallow_self_friending
		if user_id == friend_id
			errors.add( :friend_id, "Can not friend yourself" )
		end
	end
	
	def self.remove_by_ids( user_id, friend_id )
		Friendship.delete_all( { :user_id=>user_id, :friend_id=>friend_id } )
	end
	
end
