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

	def menu
		@programs = []
		if current_user
			@programs.concat( Program.find( :all, :conditions=>{ :user_id=>current_user.id } ) )
		end

		render :layout=>false
	end

	def execute
		render :json => {
			:execUrl=>"http://exec1.happysciencecoding.com:5000/execute/"+params[:programId].to_s,
			:pollUrl=>"http://exec1.happysciencecoding.com:5000/poll"
		} 
	end

	def get_id_from_name
		uid = 0
		user_name = ""

		if current_user
			uid = current_user.id
			user_name = current_user.name
		end
		program_name = params[:name]

		match = program_name.split( ":" )
		if match
			user_name = match[0]
			program_name = match[1]
			uid = User.find_by_name( user_name ).id
		end

		p = Program.find_by_name( program_name, :conditions=>{ :user_id=>uid } )
		if p
			render :json=>{ :id=>p.id }
		else
			render :json=>{ :error=>"Not found" }
		end
	end

end
