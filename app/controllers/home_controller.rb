class HomeController < ApplicationController
	def index
		@program_to_load = params[:load_program]
	end
end
