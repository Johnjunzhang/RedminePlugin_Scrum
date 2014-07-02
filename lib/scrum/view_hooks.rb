module Scrum
  class ViewHooks < Redmine::Hook::ViewListener

    render_on(:view_issues_bulk_edit_details_bottom, :partial => "scrum_hooks/issues/bulk_edit")
    render_on(:view_issues_form_details_bottom,      :partial => "scrum_hooks/issues/form")
    render_on(:view_issues_show_details_bottom,      :partial => "scrum_hooks/issues/show")
    render_on(:view_layouts_base_html_head,          :partial => "scrum_hooks/head")

  end
end
