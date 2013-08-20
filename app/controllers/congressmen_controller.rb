class CongressmenController < ApplicationController
	def show
		@congressman=Congressman.find(params[:id])
	end
	def index
		@congressmen=Congressman.order("surnames")
	end
	def test
		Congressman.all.each do |c|
			c.updatekarma
		end
		render :text=> "OK"
	end
end
