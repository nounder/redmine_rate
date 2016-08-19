module RedmineRate
  PLUGIN_ID = name.underscore.to_sym

  PATCHES = [
    'TimeEntry',
    'UsersHelper'
  ]

  DEPENDENCIES = [
  ]

  module Settings
    class << self
      def defaults
        Redmine::Plugin.find(PLUGIN_ID).settings[:default] || {}
      end

      def method_missing(method_name)
        s = Setting.method("plugin_#{PLUGIN_ID}")

        name = method_name.to_s.sub('?', '')

        if defaults.include?(name)
          m = {}
          value = defaults[name]

          case value
          when Array
            m[name] = proc { s.call[name] || value }
            m["#{name}?"] = proc { (s.call[name] || value).any? }
          when Integer
            m[name] = proc { v = s.call[name]; v.present? ? v.to_i : value }
          when TrueClass, FalseClass
            p = proc { s.call[name].to_i > 0 }
            m[name] = p
            m["#{name}?"] = p
          else
            m[name] = proc { s.call[name] || value }
            m["#{name}?"] = proc { (s.call[name] || value).present? }
          end

          m.each { |k, v| define_singleton_method(k, v) }

          send(method_name)
        else
          super
        end
      end
    end

    def self.supervisor_group
      Group.find(supervisor_group_id) if supervisor_group_id?
    end
  end

  def self.patch(patches = PATCHES)
    patches.each do |name|
      base = name.constantize
      patch_name = name.gsub('::', '')

      load "#{PLUGIN_ID}/patches/#{patch_name.underscore}_patch.rb"

      patch = "#{self.name}::Patches::#{patch_name}Patch".constantize

      next if base.included_modules.include?(patch)

      if patch.const_defined?(:ClassMethods)
        base.send(:extend, patch.const_get(:ClassMethods))
      end

      if patch.const_defined?(:InstanceMethods)
        base.send(:include, patch.const_get(:InstanceMethods))
      end

      patch.send(:included, base)
    end
  end

  def self.require_dependencies
    DEPENDENCIES.each { |name| require_dependency(name) }
  end

  def self.hook
    require_dependency "#{PLUGIN_ID}/hook"
  end

  def self.install
    plugin = self

    require_dependencies
    hook

    ActionDispatch::Reloader.to_prepare do
      plugin.patch
    end
  end

  def self.supervisor?(user = User.current)
    User.current.admin? \
    or User.current.is_or_belongs_to?(RedmineRate::Settings.supervisor_group)
  end
end
