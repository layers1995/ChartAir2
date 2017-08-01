class Category < ApplicationRecord
	has_many :fees
	belongs_to :classification
end
