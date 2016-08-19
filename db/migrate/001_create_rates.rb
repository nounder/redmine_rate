class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.column :amount, :decimal, precision: 15, scale: 2
      t.column :user_id, :integer
      t.column :project_id, :integer
      t.column :date_in_effect, :date
    end
  end
end
