require_dependency "issues_controller"

module Scrum
  module IssuesControllerPatch
    def self.included(base)
      base.class_eval do

        after_filter :save_pending_effort, :only => [:create, :update]

      private

        def save_pending_effort
          if @issue.is_task? and @issue.id and params[:issue] and params[:issue][:pending_effort]
            @issue.pending_effort = params[:issue][:pending_effort]
          end
        end

      end
    end
  end
end
