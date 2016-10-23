class RateQuery < Query
  self.queried_class = Rate

  self.available_columns = [
    QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: true),
    QueryColumn.new(:project),
    QueryColumn.new(:date_in_effect, sortable: "#{Rate.table_name}.date_in_effect",
                    caption: :label_date),
    QueryColumn.new(:amount, caption: :field_amount)
  ]

  def initialize(attributes=nil, *args)
    super(attributes)
    self.filters ||= {}
  end

  def default_columns_names
    [:project, :date_in_effect, :amount]
  end

  def initialize_available_filters
    add_available_filter 'user_id', type: :list,
                         values: User.active.map { |u| [u.name, u.id.to_s] }
    group_values = Group.all.collect {|g| [g.name, g.id.to_s] }
    add_available_filter('member_of_group',
                         type: :list_optional, values: group_values,
                         label: :label_group) unless group_values.empty?
    add_available_filter 'date_in_effect', type: :date,
                         label: :label_date
    add_available_filter 'project_id', type: :list,
                         values: User.current.projects.collect { |p| [p.name, p.id.to_s] }
  end

  def sql_for_member_of_group_field(field, operator, value)
    if operator == '*' # Any group
      groups = Group.all
      operator = '=' # Override the operator since we want to find by assigned_to
    elsif operator == "!*"
      groups = Group.all
      operator = '!' # Override the operator since we want to find by assigned_to
    else
      groups = Group.find_all_by_id(value)
    end
    groups ||= []

    members_of_groups = groups.inject([]) {|user_ids, group|
      user_ids + group.user_ids + [group.id]
    }.uniq.compact.sort.collect(&:to_s)

    '(' + sql_for_field('user_id', operator, members_of_groups, Rate.table_name, "user_id", false) + ')'
  end

  # Valid options are :order, :offset, :limit, :include
  def rates(options = {})
    order_option = [ group_by_sort_order, options[:order] ]
                     .flatten.reject(&:blank?)
    Rate
      .visible
      .where(statement)
      .includes(([:user, :project] + (options[:include] || [])).uniq)
      .order(order_option)
      .joins(joins_for_order_statement(order_option.join(',')))
      .limit(options[:limit])
      .offset(options[:offset])
  end

  def rate_count
    rates.count
  end
end
