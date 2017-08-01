class Fee < ApplicationRecord
	belongs_to :fbo
	belongs_to :category
	belongs_to :fee_type
end
