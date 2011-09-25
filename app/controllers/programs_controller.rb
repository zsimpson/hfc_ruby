class ProgramsController < ApplicationController

	def show
		begin
			p = Program.find_by_id_and_version( params[:id], params[:version] )
			render :json=>{
				:success=>true,
				:id=>p.id,
				:name=>p.name,
				:author_name=>p.user_name,
				:start_code=>p.program_version.start_code,
				:loop_code=>p.program_version.loop_code,
				:version=>p.version,
				:version_count=>p.version_count
			}
		rescue ActiveRecord::RecordNotFound
			render :json=>{ :error=>"Program or version not found" }
		end
	end

	def destroy
		@program = Program.find( params[:id] )
		if @user && @user.id == @program.user_id
			@program.destroy
			render :json => { :success=>true } 
		else
			render :json => { :error=>"Not yours to delete" } 
		end
	end

	def update
		if params[:id].to_i != 0
			# We're saving an existing program so no need to be logged in
			begin
				p = Program.find( params[:id] )
				version_count = p.new_version( params[:start_code], params[:loop_code], @user.id )
				render :json => { :success=>true, :id=>p.id, :name=>p.name, :version_count=>version_count, :version=>version_count-1, :author_name=>p.user_name } 
			rescue ActiveRecord::RecordNotFound
				render :json=>{ :error=>"Program not found" }
			end
		else
			# Saving something new so you must be logged in
			if @user
				begin
					p = Program.new_program_and_version(
						@user.id,
						params[:name],
						params[:start_code],
						params[:loop_code]
					)
					render :json => { :success=>true, :id=>p.id, :name=>p.name, :version_count=>1, :author_name=>p.user_name }
				rescue RangeError
					render :json=>{ :error=>"Duplicate name" }
				end
			else
				render :json=>{ :error=>"Not logged in" }
			end
		end
	end

	# Non REST
	##############################################################################################

	def programs_and_friends_panel
		if @user
			@my_programs = Program.find_all_by_user_id( @user.id )
			@friends_programs = @user.get_friends_programs
		end
		@new_programs = Program.find_new( 100 )
		@recent_programs = Program.find_recent( 100 )
		render :layout=>false
	end

	def programs_by_user_id
		@programs_for_user_name = User.find( params[:id] ).name
		@programs = Program.find_all_by_user_id( params[:id] ).sort{ |a,b| b.updated_at <=> a.updated_at }
		render :layout=>false
	end
	
end

