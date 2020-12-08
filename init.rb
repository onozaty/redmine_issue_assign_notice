require 'redmine'

require_dependency 'redmine_issue_assign_notice/issue_patch'
require_dependency 'redmine_issue_assign_notice/issue_hook_listener'
require_dependency 'redmine_issue_assign_notice/notice_client'

Redmine::Plugin.register :redmine_issue_assign_notice do
  name 'Redmine Issue Assign Notice plugin'
  author 'onozaty'
  description 'A plugin that notifies you that you have been assigned to an issue.'
  version '1.0.0'
  url 'https://github.com/onozaty/redmine_issue_assign_notice'
  author_url 'https://github.com/onozaty'

  settings :default => { 'notice_url' => '' }, :partial => 'settings/redmine_issue_assign_notice_settings'
end

((Rails.version > "5")? ActiveSupport::Reloader : ActionDispatch::Callbacks).to_prepare do
  require_dependency 'issue'
  unless Issue.included_modules.include? RedmineIssueAssignNotice::IssuePatch
    Issue.send(:include, RedmineIssueAssignNotice::IssuePatch)
  end
end
