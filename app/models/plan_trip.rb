class PlanTrip < ApplicationRecord
    
    validates :distance, presence: true, numericality: {greater_than: 0, less_than: 76}
    
end
