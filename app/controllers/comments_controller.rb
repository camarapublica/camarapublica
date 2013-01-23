class CommentsController < ApplicationController
	load_and_authorize_resource
	def vote
		comment=Comment.find(params[:id])
		if Vote.new(:comment_id=>comment.id,:user_id=>current_user.id,:score=>params[:score]).save
			render :text => comment.updatescore
		else
			render :text => "ERROR"
		end
	end
	def delete
		comment=Comment.find(params[:id])
		project=comment.project
		if comment.created_at > 6.hours.ago
			comment.destroy
		end
		redirect_to project
	end
end
