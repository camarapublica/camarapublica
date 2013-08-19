class CreateAuthorships < ActiveRecord::Migration
  def change
    create_table :authorships do |t|
      t.integer :project_id
      t.integer :congressman_id

      t.timestamps
    end
  end
end
