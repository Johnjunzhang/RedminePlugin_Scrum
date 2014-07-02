require_dependency "project"

module Scrum
  module ProjectPatch
    def self.included(base)
      base.class_eval do

        belongs_to :product_backlog, :class_name => "Sprint"
        has_many :sprints, :dependent => :destroy, :order => "start_date ASC, name ASC",
                 :conditions => {:is_product_backlog => false}
        has_many :sprints_and_product_backlog, :class_name => "Sprint", :dependent => :destroy,
                 :order => "start_date ASC, name ASC"

        def last_sprint
          sprints.sort{|a, b| a.end_date <=> b.end_date}.last
        end

      end
    end
  end
end
