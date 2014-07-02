require_dependency "issue"

module Scrum
  module IssuePatch
    def self.included(base)
      base.class_eval do

        belongs_to :sprint
        has_many :pending_efforts, order: "date ASC"

        acts_as_list scope: :sprint

        safe_attributes :sprint_id, if: lambda {|issue, user| user.allowed_to?(:edit_issues, issue.project)}

        before_save :update_position, if: lambda {|issue| issue.sprint_id_changed? and issue.is_pbi?}

        def has_story_points?
          ((!((custom_field_id = Scrum::Setting.story_points_custom_field_id).nil?)) and
           visible_custom_field_values.collect{|value| value.custom_field.id.to_s}.include?(custom_field_id))
        end

        def story_points
          if has_story_points? and
             !((custom_field_id = Scrum::Setting.story_points_custom_field_id).nil?) and
             !((custom_value = self.custom_value_for(custom_field_id)).nil?) and
             !((value = custom_value.value).blank?)
            value
          end
        end

        def story_points=(value)
          if has_story_points? and
             !((custom_field_id = Scrum::Setting.story_points_custom_field_id).nil?) and
             !((custom_value = self.custom_value_for(custom_field_id)).nil?) and
             custom_value.custom_field.valid_field_value?(value)
            custom_value.value = value
            custom_value.save!
          else
            raise
          end
        end

        def is_pbi?
          tracker.is_pbi?
        end

        def is_task?
          tracker.is_task?
        end

        def tasks_by_status_id
          raise "Issue is not an user story" unless is_pbi?
          statuses = {}
          IssueStatus.task_statuses.each do |status|
            statuses[status.id] = children.select{|issue| (issue.status == status) and issue.visible?}
          end
          statuses
        end

        def doers
          users = []
          users << assigned_to unless assigned_to.nil?
          time_entries = TimeEntry.all(conditions: {issue_id: id,
                                                    activity_id: Issue.doing_activities_ids})
          users.concat(time_entries.collect{|t| t.user}).uniq.sort
        end

        def reviewers
          users = []
          time_entries = TimeEntry.all(conditions: {issue_id: id,
                                                    activity_id: Issue.reviewing_activities_ids})
          users.concat(time_entries.collect{|t| t.user}).uniq.sort
        end

        def post_it_css_class(options = {})
          classes = ["post-it", "big-post-it", tracker.post_it_css_class]
          if is_pbi?
            classes << "sprint-pbi"
            if options[:draggable] and
               User.current.allowed_to?(:edit_product_backlog, project) and
               editable?
              classes << "post-it-vertical-move-cursor"
            end
          else
            classes << "sprint-task"
            if options[:draggable] and
               User.current.allowed_to?(:edit_sprint_board, project) and
               editable?
              classes << "post-it-horizontal-move-cursor"
            end
          end
          classes << "post-it-rotation-#{rand(5)}" if options[:rotate]
          classes << "post-it-small-rotation-#{rand(5)}" if options[:small_rotate]
          classes << "post-it-scale" if options[:scale]
          classes << "post-it-small-scale" if options[:small_scale]
          classes.join(" ")
        end

        def self.doer_post_it_css_class
          doer_or_reviewer_post_it_css_class(true)
        end

        def self.reviewer_post_it_css_class
          doer_or_reviewer_post_it_css_class(false)
        end

        def has_pending_effort?
          is_task? and pending_efforts.any?
        end

        def pending_effort
          if has_pending_effort?
            pending_efforts.last.effort
          end
        end

        def pending_effort=(new_effort)
          if is_task? and id and new_effort
            effort = PendingEffort.first(conditions: {issue_id: id, date: Date.today})
            if effort.nil?
              effort = PendingEffort.new(issue_id: id, date: Date.today, effort: new_effort)
            else
              effort.effort = new_effort
            end
            effort.save!
          end
        end

      private

        def update_position
          if sprint_id_was.blank?
            # From nothing to PB or Sprint
            move_issue_to_the_end_of_the_sprint
          elsif sprint and (old_sprint = Sprint.find(sprint_id_was))
            if old_sprint.is_product_backlog
              # From PB to Sprint
              move_issue_to_the_end_of_the_sprint
            elsif sprint.is_product_backlog
              # From Sprint to PB
              move_issue_to_the_begin_of_the_sprint
            else
              # From Sprint to Sprint
              move_issue_to_the_end_of_the_sprint
            end
          end
        end

        def move_issue_to_the_begin_of_the_sprint
          min_position = nil
          sprint.pbis.each do |pbi|
            min_position = pbi.position if min_position.nil? or (pbi.position < min_position)
          end
          self.position = min_position.nil? ? 1 : (min_position - 1)
        end

        def move_issue_to_the_end_of_the_sprint
          max_position = nil
          sprint.pbis.each do |pbi|
            max_position = pbi.position if max_position.nil? or (pbi.position > max_position)
          end
          self.position = max_position.nil? ? 1 : (max_position + 1)
        end

        def self.doer_or_reviewer_post_it_css_class(doer)
          classes = ["post-it", doer ? "doer-post-it" : "reviewer-post-it"]
          classes << (doer ? Scrum::Setting.doer_color : Scrum::Setting.reviewer_color)
          classes << "post-it-rotation-#{rand(5)}"
          classes.join(" ")
        end

        @@activities = nil
        def self.activities
          unless @@activities
            @@activities = Enumeration.all(conditions: {type: "TimeEntryActivity"})
          end
          @@activities
        end

        @@reviewing_activities_ids = nil
        def self.reviewing_activities_ids
          unless @@reviewing_activities_ids
            @@reviewing_activities_ids = Scrum::Setting.verification_activity_ids
          end
          @@reviewing_activities_ids
        end

        @@doing_activities_ids = nil
        def self.doing_activities_ids
          unless @@doing_activities_ids
            reviewing_activities = Enumeration.all(conditions: {id: reviewing_activities_ids})
            doing_activities = activities - reviewing_activities
            @@doing_activities_ids = doing_activities.collect{|a| a.id}
          end
          @@doing_activities_ids
        end

      end
    end
  end
end
