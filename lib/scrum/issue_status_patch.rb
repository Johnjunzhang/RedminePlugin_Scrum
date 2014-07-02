require_dependency "issue_status"

module Scrum
  module IssueStatusPatch
    def self.included(base)
      base.class_eval do

        def self.task_statuses
          IssueStatus.find(Scrum::Setting.task_status_ids, :order => "position ASC")
        end

      end
    end
  end
end
