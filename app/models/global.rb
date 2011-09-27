class Global < ActiveRecord::Base
	belongs_to :user
	has_many :global_versions, :dependent=>:destroy

	attr_accessor :global_version
	attr_accessor :version
	attr_accessor :version_count

	validates_uniqueness_of :name, :message=>"Duplicate name"

	def get_all_versions
		return GlobalVersion.all( :conditions=>{ :global_id=>self.id }, :order=>"created_at" )
	end

	def get_version_count
		return GlobalVersion.count_by_sql( ["select count(*) from global_versions where global_id=?",self.id] )
	end

	def get_version( version )
		global_versions = get_all_versions

		version = version.to_i
		if version < 0
			version = global_versions.length-1
		end

		# BOUND version
		version = [ global_versions.length-1, version ].min
		version = [ 0, version ].max
		
		return global_versions[version], version, global_versions.length
	end

	def new_version( code, user_id )
		gv = GlobalVersion.create!( :global_id=>self.id, :code=>Global.clean_code(code), :user_id=>user_id )
		return get_version_count
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
			g.global_version, g.version, g.version_count = g.get_version( version )
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