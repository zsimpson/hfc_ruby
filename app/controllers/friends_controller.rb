class FriendsController < ApplicationController
	def show
	end
	
	def create
		if current_user
			@friend = Friend.new
			@friend.user_id = current_user.id
			
			friend_user = User.find_by_name( params[:name] )
			if friend_user
				@friend.friend_user_id = friend_user.id
				
				# CHECK for self
				if current_user.id == friend_user.id
					render :json=>{ :error=>"trying to add self as friend" }
				else
					# CHECK for duplicate
					dup = Friend.find_by_user_id_and_friend_user_id( current_user.id, friend_user.id )
					if dup
						render :json=>{ :error=>"duplicate" }
					else
						@friend.save!
						render :json=>{ :success=>true }
					end
				end
			else
				render :json=>{ :error=>"Friend not found" }
			end
		else
			render :json=>{ :error=>"Not logged in" }
		end
	end

	def destroy
		if current_user
			@friend = Friend.find_by_user_id_and_friend_user_id( current_user.id, params[:id] )
			if @friend
				@friend.destroy
				render :json=>{:success=>true}
			else
				render :json=>{:error=>"friend not found"}
			end
		else
			render :json=>{:error=>"Not logged in"}
		end
	end

end
