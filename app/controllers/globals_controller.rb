class GlobalsController < ApplicationController
	def index
		@globals = Global.all
		render :layout=>false
	end

	def show
		begin
			params[:version] ||= -1
			f = Global.find_by_name_and_version( params[:id], params[:version] )
			logger.debug "*** "+f.global_version.to_s
			render :json=>{
				:success=>true,
				:id=>f.id,
				:name=>f.name,
				:code=>f.global_version.code,
				:version=>f.version,
				:version_count=>f.version_count
			}
		rescue ActiveRecord::RecordNotFound
			render :json=>{ :error=>"Global not found" }
		end
	end
	
	def update
		# We're saving an existing program so no need to be logged in
		begin
			g = Global.locate_or_create( @user.id, params[:id] )
			version_count = g.new_version( params[:code], @user.id )
			render :json => { :success=>true, :id=>g.id, :name=>g.name, :version_count=>version_count, :version=>version_count-1 } 
		rescue ActiveRecord::RecordNotFound
			render :json=>{ :error=>"Global not found" }
		end
	end
	
	def destroy
		if @user.super_user?
			begin
				@global = Global.find( params[:id] )
				@global.destroy
				render :json => { :success=>true } 
			rescue
				render :json => { :error=>"Unable to delete" } 
			end
		else
			render :json => { :error=>"Must be super user" } 
		end
	end
end

