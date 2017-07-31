class CreateUserAirplanes < ActiveRecord::Migration[5.0]
  def change
  
    # If you want to add an index for faster querying through this join:
    create_join_table :airplanes, :users do |t|
      t.index :airplane_id
      t.index :user_id
    end
    
  end
end
