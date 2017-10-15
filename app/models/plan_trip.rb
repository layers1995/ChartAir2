class PlanTrip < ApplicationRecord
    
    validates :distance, presence: true, numericality: {greater_than: 0, less_than: 76}
    validate :trip_two_hours_before
    validate :arrival_must_be_before_departure
    
    def trip_two_hours_before
        if self.arrival_time < DateTime.now - (3.0/24.0)
            errors.add(:arrival_time, "must be made 24 hours in advance")
        end
    end
    
    def arrival_must_be_before_departure
        if self.arrival_time > self.depart_time
            errors.add(:arrival_time, "You must arrive at the airport before you depart")
        end
    end
    
end
