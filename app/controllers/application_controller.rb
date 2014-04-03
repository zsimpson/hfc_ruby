class ApplicationController < ActionController::Base
	#protect_from_forgery
	# Note that to use this you need to use the ruby forms_for stuff everywhere.
	# I don't do that in all cases so I have this turned off for now

	before_filter :load_user
	before_filter :browser_type

	helper :all # include all helpers, all the time

	def render_404
		render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
	end
	
	def no_cache
		response.headers["Last-Modified"] = Time.now.httpdate
		response.headers["Expires"] = "0"
		# HTTP 1.0
		response.headers["Pragma"] = "no-cache"
		# HTTP 1.1 'pre-check=0, post-check=0' (IE specific)
		response.headers["Cache-Control"] = 'no-store, no-cache, must-revalidate, max-age=0, pre-check=0, post-check=0'
	end
	
	def browser_type
		@is_ipad = false
		@is_ie = false
		if request && request.env && request.env["HTTP_USER_AGENT"]
			@is_ipad = (request.env["HTTP_USER_AGENT"].include? "iPad") || (request.env["HTTP_USER_AGENT"].include? "iPhone")
			@is_ie = (request.env["HTTP_USER_AGENT"].include? "MSIE")
			@is_ie_9 = (request.env["HTTP_USER_AGENT"].include? "MSIE 9.")
			@is_chrome = (request.env["HTTP_USER_AGENT"].include? "Chrome")
			@is_firefox = (request.env["HTTP_USER_AGENT"].include? "Firefox")
			a = 1
		end
	end

	def load_user
		User.current_user = nil
		@user = nil
		if session[:user_id]
			User.current_user = User.find( session[:user_id] )
			@user = User.current_user
		end
	end

end
