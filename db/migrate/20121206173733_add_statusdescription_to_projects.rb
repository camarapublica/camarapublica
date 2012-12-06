class AddStatusdescriptionToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :statusdescription, :string
  end
end
