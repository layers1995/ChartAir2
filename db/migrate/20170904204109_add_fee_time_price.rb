class AddFeeTimePrice < ActiveRecord::Migration[5.0]
  def change
  	add_column :fees, :time_price, :integer
  end
end
