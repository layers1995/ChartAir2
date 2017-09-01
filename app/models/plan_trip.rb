class PlanTrip < ApplicationRecord
    
    validates :distance, presence: true, numericality: {greater_than: 0, less_than: 76}
    validate :trip_day_before
    
    def trip_day_before
        if self.arrival_time < Date.tomorrow
            errors.add(:arrival_time, "must be made 24 hours in advance")
        end
    end
    
end
