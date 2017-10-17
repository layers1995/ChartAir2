class ChangePlanTripsCityToForeignKey < ActiveRecord::Migration[5.0]
  def change
  	remove_column :plan_trips, :city, :string

  	add_reference :plan_trips, :city, index: true, foreign_key: true
  end
end
