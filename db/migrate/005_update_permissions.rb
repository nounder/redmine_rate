##
# After commit faa9c2b, permissions are scoped in project module and new
# permissions emerged.
# This migration changes old configurations (if necessary)
# in order to adjust to new logic.
class UpdatePermissions < ActiveRecord::Migration
  def self.up
    if Rate.count > 0
      # Existing users are used to have Rate working everywhere. In order to
      # prevent pain, add 'rate' to default project modules.
      say_with_time "add project module to defaults" do
        Setting.default_projects_modules += ['rate']
      end

      # Enable Rate for every project.
      say_with_time "enable module for existing project" do
        projects = Project.all.to_a

        projects.each do |project|
          project.enable_module!(:rate)
        end

        projects.length
      end

      # Update permission name.
      say_with_time "update roles" do
        roles = Role.all.to_a
        roles.select! { |role| role.permissions.include?(:view_rate) }

        roles.each do |role|
          role.permissions << :view_rates
          role.save
        end

        roles.length
      end
    end
  end
end
