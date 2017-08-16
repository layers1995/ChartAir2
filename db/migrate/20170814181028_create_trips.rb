class CreateTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :trips do |t|
      t.datetime :arrival_time
      t.integer :airport_id
      t.integer :fbo_id
      t.integer :cost
      t.string :tailnumber
      t.string :trip_status
      t.integer :user_id

      t.timestamps
    end
  end
end
