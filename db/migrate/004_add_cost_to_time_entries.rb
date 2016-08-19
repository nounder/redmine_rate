class AddCostToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :cost, :decimal, precision: 15, scale:  2
  end
end
