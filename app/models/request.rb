class Request < ApplicationRecord
    
    attr_accessor :email_confirm
    
    validates :email, presence: true
    
    #make sure that values pop up correctly
    validate :email_is_confirmed
    
    def email_is_confirmed
        if(self.email_confirm!=self.email)
            errors.add(:error, "Email and email confirmation not equal")
        end
    end
    
end
