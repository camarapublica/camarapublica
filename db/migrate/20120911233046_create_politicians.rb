class CreatePoliticians < ActiveRecord::Migration
  def change
    create_table :politicians do |t|
      t.string :firstname
      t.string :lastname
      t.string :secondlastname

      t.timestamps
    end
  end
end
