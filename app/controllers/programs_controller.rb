class ProgramsController < ApplicationController
	def show
		@program = Program.find( params[:id] )
		if @program
			@program_version = @program.get_latest_version
			if @program_version
				render :json=>{ :name=>@program.name, :code=>@program_version.code }
			else
				render :json=>{ :error=>"Program version not found" }
			end
		else
			render :json=>{ :error=>"Program not found" }
		end
	end

	def create
		if current_user
			@program = Program.find_by_user_id_and_name( current_user.id, params[:name] )
			if @program
				render :json => { :error=>"Duplicate program found" } 
			else
				@program = Program.new
				@program.user_id = current_user.id
				@program.name = params[:name]
				@program.save!

				@program_version = ProgramVersion.new
				@program_version.program_id = @program.id
				@program_version.code = params[:code]
				@program_version.save!

				render :json => { :id=>@program.id, :name=>@program.name, :code=>@program_version.code } 
			end
		else
			render :json => { :error=>"Not logged in" } 
		end
	end

	def update
		logger.debug params
		if current_user
			@program = Program.find( params[:id] )
			if @program
				@program_version = ProgramVersion.new
				@program_version.program_id = @program.id
				@program_version.code = params[:code]
				@program_version.save!
				render :json => { :id=>@program.id, :code=>@program_version.code, :name=>@program.name } 
			else
				render :json => { :error=>"Program not found" } 
			end
		else
			render :json => { :error=>"Not logged in" } 
		end
	end
	
	def destroy
		@program = Program.find( params[:id] )
		if current_user && current_user.id == @program.user_id
			@program.destroy
		end
	end

	# Non REST
	##############################################################################################

	def programs_and_friends_panel
		@programs = []
		if User.current_user
			@programs.concat( Program.find( :all, :conditions=>{ :user_id=>User.current_user.id } ) )
		end

		@friends = []
		if User.current_user
			@friends.concat( User.current_user.friends )
		end

		render :layout=>false
	end
	
end
