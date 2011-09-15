class Program < ActiveRecord::Base
	belongs_to :user
	has_many :messages
	has_many :program_versions, :dependent=>:destroy
	
	validates :user_id, :presence=>true
	validates :name, :presence=>true

	def get_latest_version
		ProgramVersion.first( :conditions=>{ :program_id => self.id }, :order=>"created_at DESC" )
	end
end
