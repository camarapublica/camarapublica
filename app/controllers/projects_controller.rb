class ProjectsController < ApplicationController
	def index
		if params[:q] && params[:q].length>0 then
			@projects=Project.search(params[:q])
		else
			if params[:order]=="id"
				@projects=Project.order("submitted_at DESC,last_discussed DESC")
			else
				@projects=Project.order("last_discussed DESC, submitted_at DESC")
			end
			@projects=@projects.where(:status=>params[:status]) if params[:status]
		end
		@projects=@projects.page(params[:page]).per(10)
	end
	def show
		@project=Project.find(params[:id])
	end
	def test
		@project=Project.find(params[:id])
		@project.fetchdata
		render :text => @project.inspect
	end	
	def comment
		@comment=Comment.new
		if params[:object]=="project"
			@comment.project_id=params[:id]
		elsif params[:object]=="comment"
			@comment.comment_id=params[:id]
		end
		@comment.user_id=current_user.id
		@comment.text=params[:text]
		@comment.save
	end
	def vote
		project=Project.find(params[:id])
		if Vote.new(:project_id=>project.id,:user_id=>current_user.id,:score=>params[:score]).save
			render :text => project.updatescore
		else
			render :text => "ERROR"
		end
	end
	def update
		project=Project.find(params[:id])
		project.fetchdata
		render :json => project
	end
end
