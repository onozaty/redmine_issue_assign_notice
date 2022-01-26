require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/redmine_issue_assign_notice/text_message', __FILE__)

class TextMesaageTest < ActiveSupport::TestCase
  fixtures :users, :projects, :trackers, :issues, :issue_statuses

  def test_create

    # ARRANGE
    message_helper = RedmineIssueAssignNotice::MessageHelper.new
    formatter = RedmineIssueAssignNotice::Formatter.create ""
    message_creater = RedmineIssueAssignNotice::TextMessage.new(message_helper, formatter)

    issue = Issue.find(1)
    old_assgined_to = User.find(1)
    new_assgined_to = User.find(2)
    note = "xxxxxxx"
    author = User.find(1)

    # ACTION
    message = message_creater.create(issue, old_assgined_to, new_assgined_to, note, author)

    # ASSERT
    assert_equal(
      {
        :text => 
          "Assign changed from _Redmine Admin_ to _John Smith_\n" +
          "[eCookbook] <http://localhost:3000/issues/1|Bug #1> Cannot print recipes (New)\n" +
          "xxxxxxx"
      },
      message)
  end

  def test_create_mention

    # ARRANGE
    message_helper = RedmineIssueAssignNotice::MessageHelper.new
    formatter = RedmineIssueAssignNotice::Formatter.create ""
    message_creater = RedmineIssueAssignNotice::TextMessage.new(message_helper, formatter)

    issue = Issue.find(1)
    old_assgined_to = nil
    new_assgined_to = User.find(2)
    note = "xxxxxxx"
    author = User.find(1)

    message_helper.stubs(:mention_target).returns("user")

    # ACTION
    message = message_creater.create(issue, old_assgined_to, new_assgined_to, note, author)

    # ASSERT
    assert_equal(
      {
        :text => 
          "@user Assign changed from _[none]_ to _John Smith_\n" +
          "[eCookbook] <http://localhost:3000/issues/1|Bug #1> Cannot print recipes (New)\n" +
          "xxxxxxx"
      },
      message)
  end

end
