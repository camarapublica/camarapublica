class Congressman < ActiveRecord::Base
  attr_accessible :karma, :names, :surnames
  has_many :authorships
  has_many :projects, through: :authorships
  def color
  	if karma>0
  		"success"
  	end
  end
end
