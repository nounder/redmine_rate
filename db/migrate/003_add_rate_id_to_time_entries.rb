class AddRateIdToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :rate_id, :integer

    add_index :time_entries, :rate_id
  end
end
