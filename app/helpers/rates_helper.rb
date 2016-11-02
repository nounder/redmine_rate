module RatesHelper
  def project_select_tag(selected = nil, user = nil)
    options = []

    if RedmineRate.supervisor?
      options << [ "<< #{l(:label_default_rate)} >>", '']
    end

    options.concat(project_with_editable_rates(user).map { |p| [p.name, p.id.to_s] })

    select_tag('rate[project_id]',
               options_for_select(options, selected.try(:id).try(:to_s)))
  end

  # Returns projects that can be used to specify rate.
  # If user is given, narrow results to they's visible projects.
  def project_with_editable_rates(user = nil)
    if RedmineRate.supervisor?
      projects = Project.active.has_module(:rate)
    else
      projects = Project.where(Project.allowed_to_condition(User.current, :edit_rates))
    end

    if user
      projects = projects.where(Project.visible_condition(user))
    end

    projects
  end

  def editable?
    User.current.admin?
  end
end
