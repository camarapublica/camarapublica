class Update < ActiveRecord::Base
  attr_accessible :date, :description, :project_id, :session, :statusdescription, :chamber
  validates_uniqueness_of :statusdescription, :scope => [:description, :date]
end
