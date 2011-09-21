class ProgramVersion < ActiveRecord::Base
	belongs_to :programs
	
#	def start_code
#		# Is the following improved by ||=??
#		return @start_code ? @start_code : ""
#	end
#
#	def loop_code
#		# Is the following improved by ||=??
#		return @loop_code ? @loop_code : ""
#	end
end
