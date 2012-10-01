class Politician < ActiveRecord::Base
  attr_accessible :firstname, :lastname, :secondlastname
  validates_uniqueness_of :firstname, :scope => [:lastname, :secondlastname]
end
