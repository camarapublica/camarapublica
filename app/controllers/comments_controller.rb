class CommentsController < ApplicationController
	load_and_authorize_resource
  before_filter :set_comment
  
	def vote
    the_vote = Vote.new(comment_id: @comment.id, user_id: current_user.id, score: params[:score])
    the_vote.save
	render :text => @comment.updatescore
	end
  
	def delete
		project = @comment.project
		if comment.created_at > 6.hours.ago
			comment.destroy
		end
		redirect_to project
	end
  
  private
    def set_comment
      @comment = Comment.find(params[:id])
    end
end
