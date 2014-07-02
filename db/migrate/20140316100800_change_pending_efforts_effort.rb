class ChangePendingEffortsEffort < ActiveRecord::Migration
  def self.up
    change_column :pending_efforts, :effort, :float
  end

  def self.down
    change_column :pending_efforts, :effort, :integer
  end
end