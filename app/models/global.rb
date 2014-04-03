class Global < ActiveRecord::Base
	include ::Versionable 

	belongs_to :user
	has_many :global_versions, :dependent=>:destroy

	attr_accessor :global_version
	attr_accessor :version
	attr_accessor :version_count

	validates_uniqueness_of :name, :message=>"Duplicate name"

	after_initialize :do_after_initialize
	
	def do_after_initialize
		@version_model_class = GlobalVersion
		@version_model_owner_class = Global
		@version_key_name = 'global_id'
	end

	def new_version( code, user_id )
		gv = GlobalVersion.create!( :global_id=>self.id, :code=>Global.clean_code(code), :user_id=>user_id )
		return version_get_count
	end
	
	def self.clean_code( code )
		lines = code.split( "\n" )
		out_lines = []
		for l in lines
			m = l.match( /^(\s*\$[A-Za-z0-9_]+\s*=\s*)(function.*)/ )
			if m
				out_lines.push( m[2] )
			else
				out_lines.push( l )
			end
		end
		return out_lines.join( "\n" )
	end
	
	def self.find_by_name_and_version( name, version )
		g = self.find_by_name( name )
		if ! g
			raise ActiveRecord::RecordNotFound
		else
			g.global_version, g.version, g.version_count = g.version_get( version )
			return g
		end
	end

	def self.locate_or_create( user_id, name )
		g = self.find_by_name( name )
		if ! g
			g = self.create!( :user_id=>user_id, :name=>name )
		end

		return g
	end

end