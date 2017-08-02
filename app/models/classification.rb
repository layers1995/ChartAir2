class Classification < ApplicationRecord
	has_many :categories
	has_many :fbos
end
