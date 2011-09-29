class ProgramVersion < ActiveRecord::Base
	belongs_to :programs

	validates :program_id, :presence=>true
end
