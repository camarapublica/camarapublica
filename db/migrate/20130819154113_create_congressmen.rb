class CreateCongressmen < ActiveRecord::Migration
  def change
    create_table :congressmen do |t|
      t.string :names
      t.string :surnames
      t.integer :karma, :default => 0

      t.timestamps
    end
  end
end
