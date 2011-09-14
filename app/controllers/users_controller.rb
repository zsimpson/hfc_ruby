class UsersController < ApplicationController

	# In HSC I used the resources model for uesers and seesion as advised
	# in Ruby on Rails 3 tutorial book.  here I have to keep compatible with
	# the user database that I already have so I'm keeping the old login code
	# even though it isn't as clean.  Specifically it is doing error checking
	# here in the controller instead of in the model as is best practice and 
	# also this is not a RESTful API

	def login
		@errors = []

		if params[:name] && params[:password]
			if params[:name].blank?
				@errors.push "Name field is blank."				
			end
			
			if params[:password].blank?
				@errors.push "Password field is blank."								
			end 			

			if @errors.length == 0
				@user = User.find_by_name_and_password( params[:name], params[:password] )
				
				if ! @user 
					@errors.push "Name and password combination not found."
				else
					session[:user_id] = @user.id
				end
			end
			
			if @errors.length == 0 		
				redirect_to "/"
				return
			end
		end
	end
	
	def create_account
		@errors = []

		if params[:name] && params[:password]
			if params[:name].blank?
				@errors.push "Name field is blank."				
			else
				existing = User.find( :first, :conditions=>["name=?",params[:name]] )
				if existing
					@errors.push "Name already taken."
				end
			end
			
			if params[:name].match( /[^A-Za-z0-9\._]/ )
				@errors.push "Names can only conatin letters, numbers, period and underscore"
			end
			
			if params[:password].blank?
				@errors.push "Password field is blank."								
			end 			
			
			if params[:password] != params[:password_verify]
				@errors.push "Passwords don't match."								
			end
			
			if @errors.length == 0
				@user = User.new
				@user.name = params[:name]
				@user.password = params[:password]
				@user.save!
				session[:user_id] = @user.id

				redirect_to "/"
				return
			end
		end
	end

	def logout
		session[:user_id] = nil
		redirect_to "/"
	end
end
