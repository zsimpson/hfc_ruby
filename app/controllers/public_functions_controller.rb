class PublicFunctionsController < ApplicationController

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

	# Non REST
	##############################################################################################

	def list
		@public_functions = PublicFunction.all
		render :layout=>false
	end
	
end

