class Program < ActiveRecord::Base
	belongs_to :user
	has_many :messages
	has_many :program_versions, :dependent=>:destroy
	
	def get_latest_version
		pv = ProgramVersion.first( :conditions=>{ :program_id => self.id }, :order=>"created_at DESC" )
	end
	
	def get_sorted_versions
		return ProgramVersion.all( :conditions=>{ :program_id=>self.id }, :order=>"created_at DESC" )
	end
end
