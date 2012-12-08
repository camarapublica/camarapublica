class AddLastDiscussedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :last_discussed, :datetime
  end
end
