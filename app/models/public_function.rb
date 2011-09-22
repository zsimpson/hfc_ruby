class PublicFunction < ActiveRecord::Base
	belongs_to :user
	has_many :function_versions

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
		fv = FunctionVersion.new( :public_function_id=>self.id, :code=>code, :user_id=>user_id )
		fv.save!
		return get_version_count
	end
	
	def self.find_by_name_and_version( name, version )
logger.debug "*** #{name} #{version}"
		p = self.find_by_name( name )
		if ! p
			raise ActiveRecord::RecordNotFound
		else
			p.public_function_version, p.version, p.version_count = p.get_version( version )
			return p
		end
	end

	def self.new_function_and_version( user_id, name, code )
		# DISALLOW duplicate name
		if self.find_by_name( name )
			raise RangeError
			return
		end
		
		f = self.new( :user_id=>user_id, :name=>name )
		f.save!

		fv = FunctionVersion.new( :public_function_id=>f.id, :code=>code, :user_id=>user_id )
		fv.save!

		return f
	end

end