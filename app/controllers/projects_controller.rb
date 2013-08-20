class ProjectsController < ApplicationController
  before_filter :set_project, except: [:index, :show, :update]
  
	def index
		if params[:q] && params[:q].length>0 then
			@projects=Project.search(params[:q])
		else
			if params[:order]=="id"
				@projects=Project.order("submitted_at DESC,last_discussed DESC")
			else
				@projects=Project.order("last_discussed DESC")
			end
			@projects=@projects.where(:status=>params[:status]) if params[:status]
		end
		@projects=@projects.page(params[:page]).per(10)
	end
  
	def show

		@project=Project.where(:remoteid=>params[:id]).first
		if @project.updated_at < 6.hours.ago
			@project.fetchdata
			puts "UPDATED !!!!!!!!!!!!!! "
		end
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
		if oldvote = Vote.where(project_id: @project.id, user_id: current_user.id).first
			oldvote.destroy
		end
    	the_vote = Vote.new(project_id: @project.id, user_id: current_user.id, score: params[:score])
    	the_vote.save
		render :text => @project.updatescore
	end
  
	def update
				@project=Project.where(:remoteid=>params[:id]).first

		@project.fetchdata
		render :json => @project
	end
  
  private
    def set_project
      @project = Project.find(params[:id])
    end
end
