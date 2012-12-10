class CommentsController < ApplicationController
	def vote
		comment=Comment.find(params[:id])
		if Vote.new(:comment_id=>comment.id,:user_id=>current_user.id,:score=>params[:score]).save
			render :text => comment.updatescore
		else
			render :text => "ERROR"
		end
	end
end
