class PublicFunctionsController < ApplicationController

	# Non REST
	##############################################################################################

	def list
		@public_functions = PublicFunction.all
		render :layout=>false
	end
	
end

