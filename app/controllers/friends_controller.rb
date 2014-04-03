class FriendsController < ApplicationController
	def create
		if @user
			begin
				@user.add_friend_by_name( params[:name] )
				render :json=>{ :success=>true }
			rescue ActiveRecord::RecordNotFound
				render :json=>{ :error=>"Friend not found" }
			rescue ActiveRecord::RecordInvalid
				render :json=>{ :error=>"Error: duplicate or trying to add yourself as a friend" }
			end
		else
			render :json=>{ :error=>"Not logged in" }
		end
	end

	def destroy
		if @user
			Friendship.remove_by_ids( @user.id, params[:id] )
			render :json=>{ :success=>true }
		else
			render :json=>{:error=>"Not logged in"}
		end
	end

end
