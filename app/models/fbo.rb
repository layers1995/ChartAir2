class Fbo < ApplicationRecord
	has_many :fees
	belongs_to :airports
end
