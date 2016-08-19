module RedmineRate
  module Patches
    module UsersHelperPatch
      def self.included(base)
        base.class_eval do
          alias_method_chain :user_settings_tabs, :rate_tab
        end
      end

      module InstanceMethods
        # Adds a rates tab to the user administration page
        def user_settings_tabs_with_rate_tab
          tabs = user_settings_tabs_without_rate_tab
          tabs << { :name => 'rates', :partial => 'users/rates', :label => :label_rates}
          return tabs
        end

        # Similar to +project_options_for_select+ but allows selecting the active value
        def project_options_for_select_with_selected(projects, selected = nil)
          options = content_tag('option', "--- #{l(:label_default_rate)} ---", :value => '')
          projects_by_root = projects.group_by(&:root)
          projects_by_root.keys.sort.each do |root|
            root_selected = (root == selected) ? 'selected' : nil

            options << content_tag('option', h(root.name), :value => root.id, :disabled => (!projects.include?(root)), :selected => root_selected)
            projects_by_root[root].sort.each do |project|
              next if project == root
              child_selected = (project == selected) ? 'selected' : nil

              options << content_tag('option', '&#187; ' + h(project.name), :value => project.id, :selected => child_selected)
            end
          end
          options
        end
      end
    end
  end
end
