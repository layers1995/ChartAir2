class AddIssueToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :issue, :string
  end
end
