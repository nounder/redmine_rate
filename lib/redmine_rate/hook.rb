module RedmineRate
  class Hook < Redmine::Hook::ViewListener
    render_on :view_account_left_bottom,
              partial: 'hooks/redmine_rate/view_account_left_bottom'
    render_on :view_users_memberships_table_row,
              partial: 'hooks/redmine_rate/view_users_memberships_table_row'
    render_on :view_projects_settings_members_table_row,
              partial: 'hooks/redmine_rate/view_projects_settings_members_table_row'

    def view_layouts_base_html_head(context = {})
      content_tag(:style, "#admin-menu a.rate-caches { background-image: url('.'); }", :type => 'text/css')
    end

    def view_users_memberships_table_header(context = {})
      content_tag(:th, l(:label_rate) + ' ' + l(:rate_label_currency))
    end

    def view_projects_settings_members_table_header(context = {})
      content_tag(:th, l(:label_rate) + ' ' + l(:rate_label_currency))
    end

    # Renders an additional table header to the membership setting
    def view_projects_settings_members_table_header(context = {})
      if context[:project].module_enabled?(:rate) \
        and User.current.allowed_to?(:edit_rates, context[:project]) || User.current.admin?
        "<th>#{l(:label_rate)}</td>"
      else
        ""
      end
    end

    def model_project_copy_before_save(context = {})
      source = context[:source_project]
      destination = context[:destination_project]

      Rate.find(:all, :conditions => {:project_id => source.id}).each do |source_rate|
        destination_rate = Rate.new

        destination_rate.attributes = source_rate.attributes.except("project_id")
        destination_rate.project = destination
        destination_rate.save # Need to save here because there is no relation on project to rate
      end
    end

    private

    def protect_against_forgery?
      false
    end

    def remote_function(options)
      ("$.ajax({url: '#{ url_for(options[:url]) }', type: '#{ options[:method] || 'GET' }', " +
       "data: #{ options[:with] ? options[:with] + '&amp;' : '' } + " +
       "'authenticity_token=' + encodeURIComponent('#{ options[:auth_token_form] }')" +
       (options[:data_type] ? ", dataType: '" + options[:data_type] + "'" : "") +
       (options[:success] ? ", success: function(response) {" + options[:success] + "}" : "") +
       (options[:before] ? ", beforeSend: function(data) {" + options[:before] + "}" : "") + "});").html_safe
    end
  end
end
