require File.expand_path('../../test_helper', __FILE__)

class IssueHookListenerTest < ActiveSupport::TestCase
  fixtures :users, :email_addresses, :user_preferences, :members, :member_roles, :roles,
           :projects, :projects_trackers, :enabled_modules, :trackers, :issues, :issue_statuses,
           :enumerations, :workflows, :journals, :journal_details, :issue_categories, :versions

  def setup
    @client = RedmineIssueAssignNotice::IssueHookListener.instance.instance_variable_get(:@client)
    Setting.plugin_redmine_issue_assign_notice = { 'notice_url' => 'https://hooks.slack.com/services/xxxx/yyyy' }
  end

  def new_issue(attributes = {})
    Issue.new({
      :project_id => 1, :tracker_id => 1, :author_id => 1, :status_id => 1, :priority_id => 4,
      :subject => 'test subject', :description => 'test description'
    }.merge(attributes))
  end

  def change_assignee(issue, notes: nil, private_notes: false)
    issue.init_journal(User.find(1), notes)
    issue.private_notes = private_notes
    issue.assigned_to = User.find(3)
    issue.save!
  end

  def test_create_notices_when_not_private

    # ARRANGE
    issue = new_issue(:assigned_to_id => 2)

    @client.expects(:notice).with { |message, _url| message[:text].include?('test description') }.once

    # ACTION
    issue.save!
  end

  def test_create_does_not_notice_when_private

    # ARRANGE
    issue = new_issue(:assigned_to_id => 2, :is_private => true)

    @client.expects(:notice).never

    # ACTION
    issue.save!
  end

  def test_change_notices_with_notes

    # ARRANGE
    issue = Issue.find(1)

    @client.expects(:notice).with { |message, _url| message[:text].include?('public note') }.once

    # ACTION
    change_assignee(issue, notes: 'public note')
  end

  def test_change_does_not_notice_when_private

    # ARRANGE
    issue = Issue.find(1)
    issue.update_column(:is_private, true)

    @client.expects(:notice).never

    # ACTION
    change_assignee(issue, notes: 'note')
  end

  def test_change_notices_without_private_notes

    # ARRANGE
    issue = Issue.find(1)

    @client.expects(:notice).with { |message, _url| !message[:text].include?('secret note') }.once

    # ACTION
    change_assignee(issue, notes: 'secret note', private_notes: true)
  end

  def test_change_does_not_notice_when_assignee_not_changed

    # ARRANGE
    issue = Issue.find(1)

    @client.expects(:notice).never

    # ACTION
    issue.init_journal(User.find(1), 'note')
    issue.subject = 'changed subject'
    issue.save!
  end
end
