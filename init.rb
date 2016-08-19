require 'redmine_rate'

Redmine::Plugin.register :redmine_rate do
  name 'Redmine Rate'
  author "Ralph Gutkowski"
  url 'http://github.com/rgtk/redmine_rate'
  author_url 'http://github.com/rgtk'
  description "Keep track not only on time but also money."
  version '0.5.0'

  requires_redmine version_or_higher: '2.3.0'

  project_module :rate do
    permission :view_rates, {}, require: :member
    permission :edit_rates, {}, require: :member
  end
end

RedmineRate.install
