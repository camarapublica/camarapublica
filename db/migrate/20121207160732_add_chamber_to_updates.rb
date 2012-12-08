class AddChamberToUpdates < ActiveRecord::Migration
  def change
    add_column :updates, :chamber, :string
  end
end
