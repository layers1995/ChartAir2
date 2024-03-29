class User < ApplicationRecord
    
    attr_accessor :remember_token, :betakey, :email_confirm, :confirm_user_agreement, :reset_token
    
    #validatations for object
    before_save { self.email = email.downcase }
    validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 }, uniqueness: true,
                    format: { with: VALID_EMAIL_REGEX }
    validates :password, presence: true, length: {minimum: 6}, confirmation: true
    has_secure_password
    
    #make sure that values pop up correctly
    validate :email, :email_is_confirmed, on: :create
    validate :betakey, :check_beta_key, on: :create
    validate :confirm_user_agreement, :check_user_agreement, on: :create
    
    #ownership
    has_and_belongs_to_many :airplanes
    has_many :plan_trips
    has_many :logins
    has_many :reports
    has_many :trips
    
    def email_is_confirmed
        if(self.email_confirm!=self.email)
            errors.add(:error, "Email and email confirmation not equal")
        end
    end
    
    def check_beta_key
         if self.betakey!="FlyInTheClouds"
             errors.add(:error, "Incorrect Beta Key")
         end
    end
    
    def check_user_agreement
        if self.confirm_user_agreement==="0"
            errors.add(:error, "Read and Agree to the User terms.")
        end
    end
    
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
    
    def self.new_token
        SecureRandom.urlsafe_base64
    end
    
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end
    
    # Sets the password reset attributes.
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest,  User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
        UserMailer.password_reset(self, self.reset_token).deliver_later
    end
    
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end
    
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
    
    # Forgets a user.
    def forget
        update_attribute(:remember_digest, nil)
    end
    
end
