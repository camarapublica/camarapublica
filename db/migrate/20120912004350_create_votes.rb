class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :politician_id
      t.integer :score

      t.timestamps
    end
  end
end
