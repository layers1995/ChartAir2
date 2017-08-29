class CreatePlanTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :plan_trips do |t|
      t.integer :user_id
      t.string :state
      t.string :city
      t.integer :distance
      t.integer :nights
      t.string :tailnumber
      t.string :filter

      t.timestamps
    end
  end
end
