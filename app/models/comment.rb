class Comment < ActiveRecord::Base
	attr_accessible :comment_id, :project_id, :score, :text, :user_id
  
	has_many :comments
	belongs_to :user
	has_many :votes
	belongs_to :project
  
  def updatescore
		score=0
		self.votes.each do |v|
			score = score + v.score
		end
		self.update_attributes(score: score)
		score
	end
end
