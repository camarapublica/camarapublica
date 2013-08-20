class AddEfficiencyToCongressmen < ActiveRecord::Migration
  def change
    add_column :congressmen, :efficiency, :integer
  end
end
