module Scrum
  class Setting

    def self.create_journal_on_pbi_position_change
      setting_or_default(:create_journal_on_pbi_position_change) == "1"
    end

    def self.doer_color
      setting_or_default(:doer_color)
    end

    def self.reviewer_color
      setting_or_default(:reviewer_color)
    end

    def self.story_points_custom_field_id
      ::Setting.plugin_scrum[:story_points_custom_field_id]
    end

    def self.task_status_ids
      collect_ids(:task_status_ids)
    end

    def self.task_tracker_ids
      collect_ids(:task_tracker_ids)
    end

    def self.pbi_tracker_ids
      collect_ids(:pbi_tracker_ids)
    end

    def self.verification_activity_ids
      collect_ids(:verification_activity_ids)
    end

    def self.tracker_id_color(id)
      setting_or_default("tracker_#{id}_color")
    end

  private

    def self.setting_or_default(setting)
      ::Setting.plugin_scrum[setting] ||
      Redmine::Plugin::registered_plugins[:scrum].settings[:default][setting]
    end

    def self.collect_ids(setting)
      (::Setting.plugin_scrum[setting] || []).collect{|value| value.to_i}
    end

  end
end
