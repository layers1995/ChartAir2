class AirplaneUser < ApplicationRecord
    
    attr_accessor :manufacturer, :model
    
    validates :tailnumber, presence: true, length: { maximum: 6 }, uniqueness: { case_sensitive: false }
    
end
