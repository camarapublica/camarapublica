class CreateUpdates < ActiveRecord::Migration
  def change
    create_table :updates do |t|
      t.string :session
      t.datetime :date
      t.text :description
      t.string :statusdescription
      t.integer :project_id

      t.timestamps
    end
  end
end
