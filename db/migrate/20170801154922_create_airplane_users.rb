class CreateAirplaneUsers < ActiveRecord::Migration[5.0]
  def change
    create_join_table :airplanes, :users do |t|
      t.index [:airplane_id, :user_id]
    end
  end
end
