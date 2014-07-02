class AddIssuesPosition < ActiveRecord::Migration
  def self.up
    add_column :issues, :position, :integer
    add_index :issues, [:position], :name => "issues_position"
  end

  def self.down
    remove_column :issues, :position
  end
end
