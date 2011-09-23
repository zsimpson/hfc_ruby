class PublicFunction < ActiveRecord::Base
	belongs_to :user
	has_many :function_versions, :dependent=>:destroy

	attr_accessor :public_function_version
	attr_accessor :version
	attr_accessor :version_count

	def get_all_versions
		return FunctionVersion.all( :conditions=>{ :public_function_id=>self.id }, :order=>"created_at" )
	end

	def get_version_count
		return FunctionVersion.count_by_sql( ["select count(*) from function_versions where public_function_id=?",self.id] )
	end

	def get_version( version )
		public_function_versions = get_all_versions

		version = version.to_i
		if version < 0
			version = public_function_versions.length-1
		end

		# BOUND version
		version = [ public_function_versions.length-1, version ].min
		version = [ 0, version ].max
		
		return public_function_versions[version], version, public_function_versions.length
	end

	def new_version( code, user_id )
		fv = FunctionVersion.new( :public_function_id=>self.id, :code=>PublicFunction.clean_code(code), :user_id=>user_id )
		fv.save!
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
		p = self.find_by_name( name )
		if ! p
			raise ActiveRecord::RecordNotFound
		else
			p.public_function_version, p.version, p.version_count = p.get_version( version )
			return p
		end
	end

	def self.locate_or_create( user_id, name )
		f = self.find_by_name( name )
		if ! f
			f = self.new( :user_id=>user_id, :name=>name )
			f.save!
		end

		return f
	end

end