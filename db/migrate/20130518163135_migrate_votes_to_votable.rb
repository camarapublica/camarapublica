class MigrateVotesToVotable < ActiveRecord::Migration
  def up
    Vote.find_each do |vote|
      if vote.politician_id then
        vote.votable_id = vote.politician_id
        vote.votable_type = 'Politician'
      elsif vote.project_id then
        vote.votable_id = vote.project_id
        vote.votable_type = 'Project'
      elsif vote.comment_id then
        vote.votable_id = vote.comment_id
        vote.votable_type = 'Comment'
      end
      vote.save
    end
  end

  def down
    Vote.find_each do |vote|
      case vote.votable_type
      when 'Politician'
        vote.politician_id = vote.votable_id
      when 'Project'
        vote.project_id = vote.votable_id
      when 'Comment'
        vote.comment_id = vote.votable_id
      end
      vote.save
    end
    Vote.update_all(votable_id: nil, votable_type: nil)
  end
end
