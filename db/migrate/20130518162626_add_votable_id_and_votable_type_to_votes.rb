class AddVotableIdAndVotableTypeToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :votable_id, :integer
    add_column :votes, :votable_type, :string, limit: 40
    add_index :votes, [:votable_id, :votable_type, :user_id], unique: true
  end
end
