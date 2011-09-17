class AssetsController < ApplicationController
	def show
		a = Asset.find( params[:id] )
		mime_type = "image/jpeg";
		mime_type = "image/png" if a.filename =~ /.png$/
		send_data( a.data, :type=>mime_type, :filename=>a.filename, :disposition=>'inline' )
	end
	
	def create
		a = Asset.new
		a.user_id = @user ? @user.id : 0
		a.filename = params[:userfile]
		a.data = params[:userfile].read
		a.save!
		
		render :text=>a.id.to_s
	end

	def destroy
		a = Asset.find( params[:id] )
		if a && @user && (@user.id == a.user_id || @user.super_user?)
			Asset.delete( a.id )
		end
		render :nothing=>true
	end

#	def update
#		existing = Asset.find( :first, :conditions=>["name = ?",params[:name]] )
#		if existing
#			render :text=>"collision"
#		else
#			a = Asset.find( params[:id] )
#			a.name = params[:name]
#			a.save!
#			render :text=>"saved"
#		end
#	end


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

end
	
