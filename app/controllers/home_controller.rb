class HomeController < ApplicationController
	def index
		if @is_ie
			render :text=>"<h2>Happy Fun Coding does not work with Internet Explorer because IE does not support the latest web standards.<br/><br/>Please try Chrome, Firefox, or Safari.</h2>"
			return
		else
		@program_to_load = params[:id]
	end
	
	def embed
		if @is_ie
			render :text=>"Happy Fun Coding does not work with Internet Explorer because IE does not support the latest web standards.<br/><br/>Please try Chrome, Firefox, or Safari."
			return
		else
		@program_to_load = params[:id]
		render :layout=>false
	end
end


			