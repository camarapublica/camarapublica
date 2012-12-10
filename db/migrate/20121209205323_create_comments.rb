class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :comment_id
      t.text :text
      t.integer :score, :default => 0

      t.timestamps
    end
  end
end
