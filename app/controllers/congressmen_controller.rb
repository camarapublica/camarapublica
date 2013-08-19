class CongressmenController < ApplicationController
	def show
		@congressman=Congressman.find(params[:id])
	end
end
