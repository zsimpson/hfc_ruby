class Asset < ActiveRecord::Base
	belongs_to :user

	validates :name, :presence=>true
	validates_uniqueness_of :name, :message=>"Duplicate name"
end
