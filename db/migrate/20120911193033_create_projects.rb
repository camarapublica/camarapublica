class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :remoteid
      t.text :title
      t.integer :score, :default=>0

      t.timestamps
    end
  end
end
