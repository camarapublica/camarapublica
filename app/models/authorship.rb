class Authorship < ActiveRecord::Base
  attr_accessible :project_id, :congressman_id
  validates_uniqueness_of :project_id, :scope => :congressman_id
  belongs_to :project
  belongs_to :congressman
end
