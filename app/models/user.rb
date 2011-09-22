include ApplicationHelper

class User < ActiveRecord::Base
	has_many :programs
	has_many :friendships
	has_many :friends, :through=>:friendships
	has_many :messages
	has_many :actions
	has_many :assets
	
	cattr_accessor :current_user

	def password=(new_password)
		@password = new_password
		self.salt = "#{id}_#{rand(100000)}_#{Time.now}"
		self.encrypted_password = encrypt_a_password( new_password, salt )
	end

	def validate_password( clear_password )
		encrypt_a_password( clear_password, salt ) == encrypted_password
	end

	def encrypt_a_password( plaintext, salt )
		salted_password = Digest::SHA256.hexdigest( plaintext + salt )
	end						   	
	
	def self.find_by_name_and_password( name, password )
		user_to_validate = self.find( :first, :conditions=>["name=?",name] )
		if user_to_validate
			if ! user_to_validate.validate_password( password )
				return nil
			end
		end
		return user_to_validate
	end
	
	def super_user?
		return name=="zack" || name == "rcorell"
	end
	
	def log_action( action )
		a = Action.new
		a.user_id = self.id
		a.action = action
		a.save!
	end
	
	def get_friends_programs
		programs_by_friend = {}
		friends_user_ids_by_name = {}

		programs = Program.find_by_sql(["select users.id as user_id, users.name as user_name, programs.id as program_id, programs.name as program_name from friendships,  programs, users where friendships.friend_id = programs.user_id and friendships.user_id = ? and users.id = friendships.friend_id order by upper(users.name)", self.id])
		for i in programs
			programs_by_friend[ i[:user_id] ] ||= {} 
			programs_by_friend[ i[:user_id] ][ :user_name ] = i[:user_name]
			(programs_by_friend[ i[:user_id] ][ :programs ] ||= []).push( {:program_id=>i[:program_id], :program_name=>i[:program_name]} )
			friends_user_ids_by_name[ i[:user_name] ] = i[:user_id]
		end
		
		# MAKE a nice list of names with a list of their programs
		friends_programs = []
		for f in friends_user_ids_by_name.keys.sort{ |a,b| a.downcase <=> b.downcase }
			user_id = friends_user_ids_by_name[ f ]
			friends_programs.push( {:user_name=>f, :user_id=>user_id, :programs=>programs_by_friend[user_id][:programs] } )
		end
		
		return friends_programs
	end
				
end
