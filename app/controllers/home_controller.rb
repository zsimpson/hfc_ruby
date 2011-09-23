class HomeController < ApplicationController
	def index
		@program_to_load = params[:id]
	end
	
	def embed
		@program_to_load = params[:id]
		render :layout=>false
	end
end
