class PublicFunctionsController < ApplicationController
	def index
		@public_functions = PublicFunction.all
		render :layout=>false
	end

	def show
		begin
			params[:version] ||= -1
			f = PublicFunction.find_by_name_and_version( params[:id], params[:version] )
			render :json=>{
				:success=>true,
				:id=>f.id,
				:name=>f.name,
				:code=>f.public_function_version.code,
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
			p = PublicFunction.locate_or_create( @user.id, params[:id] )
			version_count = p.new_version( params[:code], @user.id )
			render :json => { :success=>true, :id=>p.id, :name=>p.name, :version_count=>version_count, :version=>version_count-1 } 
		rescue ActiveRecord::RecordNotFound
			render :json=>{ :error=>"Program not found" }
		end
	end
	
	def destroy
		if @user.super_user?
			begin
				@public_function = PublicFunction.find( params[:id] )
				@public_function.destroy
				render :json => { :success=>true } 
			rescue
				render :json => { :error=>"Unable to delete" } 
			end
		else
			render :json => { :error=>"Must be super user" } 
		end
	end
end

