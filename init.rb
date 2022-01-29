require 'redmine'

require File.expand_path('../lib/redmine_issue_assign_notice/issue_patch', __FILE__)
require File.expand_path('../lib/redmine_issue_assign_notice/issue_hook_listener', __FILE__)
require File.expand_path('../lib/redmine_issue_assign_notice/notice_client', __FILE__)

Redmine::Plugin.register :redmine_issue_assign_notice do
  name 'Redmine Issue Assign Notice plugin'
  author 'onozaty'
  description 'A plugin that notifies you that you have been assigned to an issue.'
  version '2.1.0-beta1'
  url 'https://github.com/onozaty/redmine_issue_assign_notice'
  author_url 'https://github.com/onozaty'

  settings :default => { 'notice_url' => '' }, :partial => 'settings/redmine_issue_assign_notice_settings'
end

require 'issue'
unless Issue.included_modules.include? RedmineIssueAssignNotice::IssuePatch
  Issue.send(:include, RedmineIssueAssignNotice::IssuePatch)
end
