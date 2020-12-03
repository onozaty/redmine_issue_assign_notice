module RedmineIssueAssignNotice
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        after_create :create_from_issue_for_assign_notice
        after_save :save_from_issue_for_assign_notice
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def create_from_issue_for_assign_notice
        @create_already_fired = true
        Redmine::Hook.call_hook(:redmine_issue_assign_notice_new, { :issue => self })
        return true
      end

      def save_from_issue_for_assign_notice
        if not @create_already_fired
          Redmine::Hook.call_hook(:redmine_issue_assign_notice_change, { :issue => self, :journal => self.current_journal}) unless self.current_journal.nil?
        end
        return true
      end

    end
  end
end