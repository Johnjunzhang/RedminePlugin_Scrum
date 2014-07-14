class Sprint < ActiveRecord::Base

  belongs_to :user
  belongs_to :project
  has_many :issues, :dependent => :destroy
  has_many :efforts, :class_name => "SprintEffort", :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:project_id]
  validates_length_of :name, :maximum => 60
  validates_presence_of :name

  validates_presence_of :start_date

  validates_presence_of :end_date
  
  before_destroy :update_project_product_backlog

  def to_s
    name
  end

  def is_product_backlog?
    self.is_product_backlog
  end

  def pbis
    issues.all(conditions: {tracker_id: Scrum::Setting.pbi_tracker_ids},
               order: "position ASC").select{|issue| issue.visible?}
  end

  def story_points
    pbis.collect{|pbi| pbi.story_points.to_f}.compact.sum
  end

  def remained_story_points(date, story_points, closed_stories)
    closedPoints = closed_stories.select { |pbi| pbi.closed_on.getlocal.to_date <= date }.collect { |pbi| pbi.story_points.to_f }.compact.sum
    story_points - closedPoints
  end

  def closed_stories
    pbis.select{|pbi| pbi.status == IssueStatus.where(:is_closed => true).first}
  end

  def tasks
    issues.all(conditions: {tracker_id: Scrum::Setting.task_tracker_ids}).select{|issue| issue.visible?}
  end

  def estimated_hours
    tasks.collect{|task| task.estimated_hours}.compact.sum
  end

  def self.fields_for_order_statement(table = nil)
    table ||= table_name
    ["(CASE WHEN #{table}.end_date IS NULL THEN 1 ELSE 0 END)",
     "#{table}.end_date",
     "#{table}.name",
     "#{table}.id"]
  end

  scope :sorted, order(fields_for_order_statement)

private

  def update_project_product_backlog
    if is_product_backlog?
      project.product_backlog = nil
      project.save!
    end
  end

end
