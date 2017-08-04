class AirplaneUser < ApplicationRecord
    
    validates :tailnumber, presence: true, length: { maximum: 10 }, uniqueness: { case_sensitive: false }
    
end
