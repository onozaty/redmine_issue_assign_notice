require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/redmine_issue_assign_notice/issue_hook_listener', __FILE__)

class IssueHookListenerTest < ActiveSupport::TestCase
  fixtures :users, :projects, :trackers, :issues, :issue_statuses, :enumerations

  def setup
    @listener = RedmineIssueAssignNotice::IssueHookListener.instance
    Setting.plugin_redmine_issue_assign_notice = { 'notice_url' => 'https://hooks.slack.com/services/xxxx/yyyy' }
  end

  def test_redmine_issue_assign_notice_new_does_not_notice_when_private

    # ARRANGE
    issue = Issue.find(1)
    issue.is_private = true
    issue.assigned_to = User.find(2)

    @listener.instance_variable_get(:@client).expects(:notice).never

    # ACTION
    @listener.redmine_issue_assign_notice_new(:issue => issue)
  end

  def test_redmine_issue_assign_notice_new_notices_when_not_private

    # ARRANGE
    issue = Issue.find(1)
    issue.is_private = false
    issue.assigned_to = User.find(2)

    @listener.instance_variable_get(:@client).expects(:notice).once

    # ACTION
    @listener.redmine_issue_assign_notice_new(:issue => issue)
  end

  def test_redmine_issue_assign_notice_change_does_not_notice_when_private

    # ARRANGE
    issue = Issue.find(1)
    issue.is_private = true

    journal = Journal.new
    journal.user = User.find(1)
    journal.notes = "note"
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'assigned_to_id', :old_value => 1, :value => 2)
    journal.details << detail

    @listener.instance_variable_get(:@client).expects(:notice).never

    # ACTION
    @listener.redmine_issue_assign_notice_change(:issue => issue, :journal => journal)
  end
end
