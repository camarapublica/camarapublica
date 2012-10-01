class Vote < ActiveRecord::Base
  attr_accessible :politician_id, :score, :project_id
  validates_uniqueness_of :politician_id, :scope => [:score, :project_id]
end
