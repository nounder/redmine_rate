module RatesHelper
  def project_select_tag(rate)
    options = []

    if RedmineRate.supervisor?
      options << [ "<< #{l(:label_default_rate)} >>", '']
    end

    options.concat(rate.selectable_projects.map { |p| [p.name, p.id.to_s] })

    select_tag('rate[project_id]',
               options_for_select(options, rate.project.try(:id).to_s))
  end

  def editable?
    User.current.admin?
  end
end
