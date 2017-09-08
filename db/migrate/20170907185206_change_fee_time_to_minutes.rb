class ChangeFeeTimeToMinutes < ActiveRecord::Migration[5.0]
  def up
    change_column :fees, :start_time, 'integer USING CAST(column_name AS integer)'
    change_column :fees, :end_time, 'integer USING CAST(column_name AS integer)'
  end

  def down
    change_column :fees, :start_time, :time
    change_column :fees, :end_time, :time
  end
end
