class Airport < ApplicationRecord
	has_many :fbos
	belongs_to :cities
end
