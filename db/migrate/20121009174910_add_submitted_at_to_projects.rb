class AddSubmittedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :submitted_at, :date
  end
end
