class Program < ActiveRecord::Base
	# @TODO: Refactor to share this code between HSC and HFC
	
	include ::Versionable 

	belongs_to :user
	has_many :messages
	has_many :program_versions, :dependent=>:destroy

	attr_accessor :program_version
	attr_accessor :version
	attr_accessor :version_count
	
	validates :user_id, :presence=>true
	validates :name, :presence=>true
	validates_uniqueness_of :name, :message=>"Duplicate name"

	after_initialize :do_after_initialize
	
	def do_after_initialize
		@version_model_class = ProgramVersion
		@version_model_owner_class = Program
		@version_key_name = 'program_id'
	end

	def new_version( start_code, loop_code, user_id, icon )
		pv = ProgramVersion.create!( :program_id=>self.id, :start_code=>start_code, :loop_code=>loop_code, :user_id=>user_id )
		
		# TOUCH the program too so that the updated_at will reflect the time that this version was created
		self.icon = icon
		self.touch
		self.save!
		
		return version_get_count
	end
	
	def self.normalize_name( name )
		name.gsub!( ' ', '_' )
		name.gsub!( /[^A-Za-z0-9_-]/, '' )
		return name
	end
	
	def self.new_program_and_version( user_id, name, start_code, loop_code, icon )
		p = self.create!( :user_id=>user_id, :name=>self.normalize_name(name), :icon=>icon )
		pv = ProgramVersion.create!( :program_id=>p.id, :start_code=>start_code, :loop_code=>loop_code, :user_id=>user_id )
		return p
	end

	# This is really stupid.  I need to get the @version* variables setup to
	# use the Versionable mixin but I can't use extend because I get those those arguments into the class
	# So instead I have to have these duplicate these little helper methods that pass along the message to an instance of the class

	def self.version_all_newest( count )
		programs = Program.new.version_all_newest( count )
	end

	def self.version_all_recent_edits( count )
		return Program.new.version_all_recent_edits( count )
	end 
	
end
