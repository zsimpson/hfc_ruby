class PublicFunction < ActiveRecord::Base
	belongs_to :user
	has_many :function_versions
end