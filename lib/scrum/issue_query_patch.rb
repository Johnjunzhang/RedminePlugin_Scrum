require_dependency "issue_query"

module Scrum
  module IssueQueryPatch
    def self.included(base)
      base.class_eval do

        self.available_columns << QueryColumn.new(:sprint, :sortable => lambda {Sprint.fields_for_order_statement}, :groupable => true)

        def initialize_available_filters_with_scrum
          filters = initialize_available_filters_without_scrum
          if project
            sprints = project.sprints_and_product_backlog
            if sprints.any?
              add_available_filter "sprint_id",
                                   :type => :list_optional,
                                   :values => sprints.sort.collect{|s| [s.name, s.id.to_s]}
              add_associations_custom_fields_filters :sprint
            end
          end
          filters
        end
        alias_method_chain :initialize_available_filters, :scrum

        def issues_with_scrum(options = {})
          options[:include] ||= {}
          options[:include] << :sprint
          issues_without_scrum(options)
        end
        alias_method_chain :issues, :scrum

        def issue_ids_with_scrum(options = {})
          options[:include] ||= {}
          options[:include] << :sprint
          issue_ids_without_scrum(options)
        end
        alias_method_chain :issue_ids, :scrum

      end
    end
  end
end
