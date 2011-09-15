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
		if User.current_user
			@program = Program.find_by_user_id_and_name( User.current_user.id, params[:name] )
			if @program
				render :json => { :error=>"Duplicate program found" } 
			else
				@program = Program.new
				@program.user_id = User.current_user.id
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
		if User.current_user
			@program = Program.find( params[:id] )
			if @program
				@program_version = ProgramVersion.new
				@program_version.program_id = @program.id
				@program_version.loop_code = params[:loop_code]
				@program_version.start_code = params[:start_code]
				@program_version.save!
				render :json => { :id=>@program.id, :loop_code=>@program_version.loop_code, :start_code=>@program_version.start_code, :name=>@program.name } 
			else
				render :json => { :error=>"Program not found" } 
			end
		else
			render :json => { :error=>"Not logged in" } 
		end
	end
	
	def destroy
		@program = Program.find( params[:id] )
		if User.current_user && User.current_user.id == @program.user_id
			@program.destroy
			render :json => { :success=>true } 
		else
			render :json => { :error=>"Not your to delete" } 
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
	
	def load_by_symbol
		if params[:symbol].match( /^[0-9]+$/ )
			@program = Program.find( params[:symbol] )
		else
			user_name = User.current_user ? User.current_user.name : ""
			prog_name = params[:symbol]
			match = params[:symbol].match( /^([^:]+):(.*)$/ )
			if match
				user_name = match[1]
				prog_name = match[2]
			end
			@program = Program.find_by_sql( [ "select programs.id from programs, users where programs.name = ? and programs.user_id = users.id and users.name = ?", prog_name, user_name ] ) 
		end

		if @program
			program_version = @program.get_latest_version
			if program_version
				render :json=>{ :success=>true, :name=>@program.name, :startCode=>program_version.start_code, :loopCode=>program_version.loop_code }
			else
				render :json=>{ :error=>"Program version not found" }
			end
		else
			render :json=>{ :error=>"Program not found" }
		end
	end
	
end
