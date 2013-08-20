class CongressmenController < ApplicationController
	def show
		@congressman=Congressman.find(params[:id])
	end
	def index
		@congressmen=Congressman.order("surnames")
	end
end
