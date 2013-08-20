class Congressman < ActiveRecord::Base
  attr_accessible :karma, :names, :surnames, :efficiency
  has_many :authorships
  has_many :projects, through: :authorships
  def color
  	if self.karma>0
  		"success"
  	elsif self.karma<0
  		"important"
  	end
  end


end
