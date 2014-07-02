class ScrumController < ApplicationController

  menu_item :scrum

  before_filter :find_issue, only: [:change_story_points, :change_pending_effort,
                                    :change_assigned_to, :create_time_entry]
  before_filter :find_sprint, only: [:new_pbi, :create_pbi]
  before_filter :authorize, except: [:new_pbi, :create_pbi]
  before_filter :authorize_add_issues, only: [:new_pbi, :create_pbi]

  helper :scrum
  helper :timelog
  helper :custom_fields

  def change_story_points
    begin
      @issue.story_points = params[:value]
      status = 200
    rescue
      status = 503
    end
    render nothing: true, status: status
  end

  def change_pending_effort
    @issue.pending_effort = params[:value]
    render nothing: true, status: 200
  end

  def change_assigned_to
    @issue.init_journal(User.current)
    @issue.assigned_to = params[:value].blank? ? nil : User.find(params[:value].to_i)
    @issue.save!
    render_task(@project, @issue, params)
  end

  def create_time_entry
    time_entry = TimeEntry.new(params[:time_entry])
    time_entry.project_id = @project.id
    time_entry.issue_id = @issue.id
    time_entry.user_id = params[:time_entry][:user_id]
    call_hook(:controller_timelog_edit_before_save, {params: params, time_entry: time_entry})
    time_entry.save!
    render_task(@project, @issue, params)
  end

  def new_pbi
    @pbi = Issue.new
    @pbi.project = @project
    @pbi.author = User.current
    @pbi.tracker = @project.trackers.find(params[:tracker_id])
    @pbi.sprint = @sprint
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_pbi
    begin
      @continue = !(params[:create_and_continue].nil?)
      @pbi = Issue.new
      @pbi.project = @project
      @pbi.author = User.current
      @pbi.sprint = @sprint
      @pbi.tracker_id = params[:issue][:tracker_id]
      @pbi.subject = params[:issue][:subject]
      @pbi.category_id = params[:issue][:category_id]
      @pbi.description = params[:issue][:description]
      @pbi.custom_field_values = params[:issue][:custom_field_values] unless params[:issue][:custom_field_values].nil?
      @pbi.save!
      @pbi.story_points = params[:issue][:story_points]
    rescue Exception => @exception
    end
    respond_to do |format|
      format.js
    end
  end

private

  def render_task(project, task, params)
    render partial: "post_its/sprint_board/task",
           status: 200,
           locals: {project: project,
                    task: task,
                    pbi_status_id: params[:pbi_status_id],
                    other_pbi_status_ids: params[:other_pbi_status_ids].split(","),
                    task_id: params[:task_id]}
  end

  def find_sprint
    @sprint = Sprint.find(params[:sprint_id])
    @project = @sprint.project
  rescue
    render_404
  end

  def authorize_add_issues
    if User.current.allowed_to?(:add_issues, @project)
      return true
    else
      render_403
      return false
    end
  end

end
