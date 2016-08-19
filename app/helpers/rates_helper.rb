module RatesHelper
  def project_select_tag(selected = nil)
    options = []

    if RedmineRate.supervisor?
      options << [ "<< #{l(:label_default_rate)} >>", '']
    end

    options.concat(project_with_editable_rates.map { |p| [p.name, p.id.to_s] })

    select_tag('rate[project_id]',
               options_for_select(options, selected.try(:id).try(:to_s)))
  end

  def project_with_editable_rates
    if RedmineRate.supervisor?
      Project.active.has_module(:rate)
    else
      Project.where(Project.allowed_to_condition(User.current, :edit_rates))
    end
  end

  def editable?
    User.current.admin?
  end
end
