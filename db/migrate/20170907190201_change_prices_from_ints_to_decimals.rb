class ChangePricesFromIntsToDecimals < ActiveRecord::Migration[5.0]
  def up
    change_column :fees, :price, :decimal, precision: 11, scale: 2
    change_column :fees, :time_price, :decimal, precision: 11, scale: 2
    change_column :fees, :unit_price, :decimal, precision: 11, scale: 2
  end

  def down
    change_column :fees, :price, :integer
    change_column :fees, :time_price, :integer
    change_column :fees, :unit_price, :integer
  end
end
