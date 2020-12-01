require 'redmine'

require_dependency 'redmine_issue_assign_notice/listener'

Redmine::Plugin.register :redmine_issue_assign_notice do
  name 'Redmine Issue Assign Notice plugin'
  author 'onozaty'
  description 'A plugin that notifies you that you have been assigned to an issue.'
  version '0.0.1'
  url 'https://github.com/onozaty/redmine_issue_assign_notice'
  author_url 'https://github.com/onozaty'
end

((Rails.version > "5")? ActiveSupport::Reloader : ActionDispatch::Callbacks).to_prepare do
	require_dependency 'issue'
	unless Issue.included_modules.include? RedmineIssueAssignNotice::IssuePatch
		Issue.send(:include, RedmineIssueAssignNotice::IssuePatch)
	end
end
