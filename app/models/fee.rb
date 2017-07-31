class Fee < ApplicationRecord
	belongs_to :fbos
	belongs_to :categories
	belongs_to :fee_types
end
