class AddProjectsProductBacklogId < ActiveRecord::Migration
  def self.up
    add_column :projects, :product_backlog_id, :integer
    add_index :projects, [:product_backlog_id], :name => "projects_product_backlog_id"
  end

  def self.down
    remove_column :projects, :product_backlog_id
  end
end
