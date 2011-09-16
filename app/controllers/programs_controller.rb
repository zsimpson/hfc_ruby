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
	
	def load
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
			program_versions = @program.get_sorted_versions
			if program_versions && program_versions.length > 0
				version_number = params[:version_number].to_i
				version_number = [ program_versions.length-1, version_number ].min
				version_number = [ 0, version_number ].max
				program_version = program_versions[ version_number ]
				version_count = program_versions.length
				if ! program_version.start_code
					program_version.start_code = ""
				end
				if ! program_version.loop_code
					program_version.loop_code = ""
				end
				render :json=>{
					:success=>true,
					:id=>@program.id,
					:name=>@program.name,
					:start_code=>program_version.start_code,
					:loop_code=>program_version.loop_code,
					:version_number=>version_number,
					:version_count=>version_count
				}
			else
				render :json=>{ :error=>"Program version not found" }
			end
		else
			render :json=>{ :error=>"Program not found" }
		end
	end
	
	def save
		if params[:id] && params[:id].to_i != 0
			# We're saving an existing program
			@program = Program.find( params[:id] )
			if @program
				program_versions = @program.get_sorted_versions
				@program_version = ProgramVersion.new
				@program_version.program_id = @program.id
				@program_version.loop_code = params[:loop_code]
				@program_version.start_code = params[:start_code]
				@program_version.save!
				render :json => { :success=>true, :id=>params[:id], :name=>@program.name, :version_count=>program_versions.length+1 } 
			else
				render :json=>{ :error=>"Program not found" }
			end
		else
			# Either we're saving something new that had no idea or we're doing a save as to make a new program
			if User.current_user
				params[:name].gsub!( ' ', '_' )
				params[:name].gsub!( /[^A-Za-z0-9_-]/, '' )
			
				if Program.find_by_name( params[:name] )
					render :json=>{ :error=>"Duplicate name" }
				else
					@program = Program.new
					@program.user_id = User.current_user.id
					@program.name = params[:name]
					@program.save!
					@program_version = ProgramVersion.new
					@program_version.program_id = @program.id
					@program_version.loop_code = params[:loop_code]
					@program_version.start_code = params[:start_code]
					@program_version.save!
					render :json => { :success=>true, :id=>params[:id], :name=>@program.name, :version_count=>1 } 
				end
			else
				render :json=>{ :error=>"Not logged in" }
			end
		end
	end
end

