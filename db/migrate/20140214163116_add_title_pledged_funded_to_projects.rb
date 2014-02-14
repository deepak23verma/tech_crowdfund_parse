class AddTitlePledgedFundedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :title, :string
    add_column :projects, :pledged, :string
    add_column :projects, :funded, :string
  end
end
