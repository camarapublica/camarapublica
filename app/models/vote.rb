class Vote < ActiveRecord::Base
  attr_accessible :politician_id, :score, :project_id, :user_id, :comment_id
  validates_uniqueness_of :project_id, :scope => :user_id, :allow_nil => true
  validates_uniqueness_of :comment_id, :scope => :user_id, :allow_nil => true
end
