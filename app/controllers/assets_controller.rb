class AssetsController < ApplicationController
	def show
		a = Asset.find( params[:id] )
		mime_type = "image/jpeg";
		mime_type = "image/png" if a.filename =~ /.png$/
		send_data( a.data, :type=>mime_type, :filename=>a.filename, :disposition=>'inline' )
	end
	
	def destroy
		a = Asset.find( params[:id] )
		if a && @user && (@user.id == a.user_id || @user.super_user?)
			Asset.delete( a.id )
		end
		render :nothing=>true
	end

	# Non-REST
	################################################################################
	
	def show_by_name
		a = Asset.find( :first, :conditions=>["name=?",params[:name]] )
		mime_type = "image/jpeg";
		mime_type = "image/png" if a.filename =~ /.png$/
		send_data( a.data, :type=>mime_type, :filename=>a.filename, :disposition=>'inline' )
	end

	def get_art_page
		render :layout=>false
	end
	
	def return_as_file
		send_data( CGI::unescape(params[:data]), :type=>"image/svg", :filename=>params[:filename], :disposition=>'inline' )
	end
	
	def upload
		if params[:qqfile].class == String
			begin
				a = Asset.new
				a.user_id = @user ? @user.id : 0
				a.name = params[:name]
				a.filename = params[:qqfile]
				a.data = request.body.read
				a.save!
				render :json=>{ :success=>true }
			rescue
				render :json=>{ :error=>"Invalid or duplicate name" }
			end
		end

	end

end
	
