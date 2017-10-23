class Fbo < ApplicationRecord
	
	include Friendlyable
	has_many :fees
	belongs_to :airport
	belongs_to :classification, optional: true
	
end
