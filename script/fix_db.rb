require 'rubygems'
require 'active_record'
require '../app/models/program'
require '../app/models/program_version'

database_yaml = IO.read('../config/database.yml')
databases = YAML::load(database_yaml)
ActiveRecord::Base.establish_connection(databases["development"])

programs = Program.all
for p in programs
	pv = ProgramVersion.new
	pv.start_code = p.start_code
	pv.loop_code = p.loop_code
	pv.program_id = p.id
	pv.save!
end

