class Program < ActiveRecord::Base
	belongs_to :user
	has_many :messages
	has_many :program_versions, :dependent=>:destroy

	attr_accessor :program_version
	attr_accessor :version
	attr_accessor :version_count

	def get_all_versions
		return ProgramVersion.all( :conditions=>{ :program_id=>self.id }, :order=>"created_at" )
	end

	def get_version_count
		return ProgramVersion.count_by_sql( ["select count(*) from program_versions where program_id=?",self.id] )
	end

	def get_version( version )
		program_versions = get_all_versions

		version = version.to_i
		if version < 0
			version = program_versions.length-1
		end

		# BOUND version
		version = [ program_versions.length-1, version ].min
		version = [ 0, version ].max
		
		return program_versions[version], version, program_versions.length
	end

	def new_version( start_code, loop_code, user_id )
		pv = ProgramVersion.new( :program_id=>self.id, :start_code=>start_code, :loop_code=>loop_code, :user_id=>user_id )
		pv.save!
		
		# TOUCH the program too so that the updated_at will reflect the time that this version was created
		self.touch
		self.save!
		
		return get_version_count
	end
	
	def user_name
		return User.find( user_id ).name
	end
	
	def self.find_by_id_and_version( id, version )
		p = self.find( id )
		p.program_version, p.version, p.version_count = p.get_version( version )
		return p
	end
	
	def self.find_new( count )
		# Until I find out from Corey how to do this kind of thing correctly...
		return Program.find_by_sql( "select users.name as user_name, programs.* from users, programs where users.id=programs.user_id order by programs.created_at desc limit 100" );
		#return Program.order( "created_at desc" ).limit( count ) 
	end

	def self.find_recent( count )
		# Until I find out from Corey how to do this kind of thing correctly...
		return Program.find_by_sql( "select users.name as user_name, programs.* from users, programs where users.id=programs.user_id order by programs.updated_at desc limit 100" );
		#return Program.order( "created_at desc" ).limit( count ) 
	end

	def self.normalize_name( name )
		name.gsub!( ' ', '_' )
		name.gsub!( /[^A-Za-z0-9_-]/, '' )
		return name
	end
	
	def self.new_program_and_version( user_id, name, start_code, loop_code )
		# This is going to have to either exception or return an invalid

		# DISALLOW duplicate name
		if self.find_by_name( name )
			raise RangeError
			return
		end
		
		p = self.new( :user_id=>user_id, :name=>self.normalize_name(name) )
		p.save!

		pv = ProgramVersion.new( :program_id=>p.id, :start_code=>start_code, :loop_code=>loop_code, :user_id=>user_id )
		pv.save!

		return p
	end
	
end
