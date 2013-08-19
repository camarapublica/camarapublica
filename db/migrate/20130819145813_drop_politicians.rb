class DropPoliticians < ActiveRecord::Migration
  def up
  	drop_table :politicians
  end

  def down
  end
end
