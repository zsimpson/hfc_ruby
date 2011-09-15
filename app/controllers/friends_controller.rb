class FriendsController < ApplicationController
	def create
		if User.current_user
			@friendship = Friendship.new
			@friendship.user_id = User.current_user.id
			
			friend_user = User.find_by_name( params[:name] )
			if friend_user
				@friendship.friend_id = friend_user.id
				
				# CHECK for self
				if User.current_user.id == friend_user.id
					render :json=>{ :error=>"trying to add self as friend" }
				else
					# CHECK for duplicate
					dup = Friendship.find_by_user_id_and_friend_id( User.current_user.id, friend_user.id )
					if dup
						render :json=>{ :error=>"duplicate" }
					else
						@friendship.save!
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
		if User.current_user
			@friendship = Friendship.find_by_user_id_and_friend_id( User.current_user.id, params[:id] )
			logger.debug "**friend destroy** "+@friendship.to_s
			if @friendship
				Friendship.delete_all( { :user_id=>User.current_user.id, :friend_id=>params[:id] } )
				render :json=>{ :success=>true }
			else
				render :json=>{ :error=>"friend not found" }
			end
		else
			render :json=>{:error=>"Not logged in"}
		end
	end

end
