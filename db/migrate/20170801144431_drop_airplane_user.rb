class DropAirplaneUser < ActiveRecord::Migration[5.0]
  def change
    
    def up
      drop_table :airplanes_users
    end

    def down
      raise ActiveRecord::IrreversibleMigration
    end
  
  end
end
