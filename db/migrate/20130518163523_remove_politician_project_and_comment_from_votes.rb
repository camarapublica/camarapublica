class RemovePoliticianProjectAndCommentFromVotes < ActiveRecord::Migration
  def up
    remove_column :votes, :politician_id
    remove_column :votes, :project_id
    remove_column :votes, :comment_id
  end

  def down
    add_column :votes, :politician_id, :integer
    add_column :votes, :project_id, :integer
    add_column :votes, :comment_id, :integer
  end
end
