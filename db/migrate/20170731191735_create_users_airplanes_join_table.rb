class CreateUsersAirplanesJoinTable < ActiveRecord::Migration[5.0]
  def change
  	create_join_table :users, :airplanes do |t|
  		t.index :airplane_id
  		t.index :user_id
  	end
  end
end
