class ProjectsController < ApplicationController
	def index
		@projects=Project.order("submitted_at DESC").page(params[:page]).per(10)
	end
	def show
		@project=Project.find(params[:id])
	end
	def test
		@project=Project.find(params[:id])
		@project.fetchdata
		render :text => @project.inspect
	end	
end
