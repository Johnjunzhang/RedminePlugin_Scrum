require_dependency "user"

module Scrum
  module UserPatch
    def self.included(base)
      base.class_eval do

        has_many :sprint_efforts, :dependent => :destroy

      end
    end
  end
end
