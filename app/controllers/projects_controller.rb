class ProjectsController < ApplicationController
	def index
		@projects=Project.order("id DESC").page(params[:page]).per(10)
	end
end
