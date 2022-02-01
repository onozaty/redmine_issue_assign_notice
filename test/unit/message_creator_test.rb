require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/redmine_issue_assign_notice/message_creator', __FILE__)

class MesaageCreatorTest < ActiveSupport::TestCase
  fixtures :users, :projects, :trackers, :issues, :issue_statuses

  def test_create

    # ARRANGE
    url = ""
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    issue = Issue.find(1)
    old_assgined_to = User.find(1)
    new_assgined_to = User.find(2)
    note = "xxxxxxx"
    author = User.find(1)

    # ACTION
    message = message_creator.create(issue, old_assgined_to, new_assgined_to, note, author)

    # ASSERT
    assert_equal(
      {
        :text => 
          "Assign changed from _Redmine Admin_ to _John Smith_\n" +
          "[eCookbook] [Bug #1](http://localhost:3000/issues/1) Cannot print recipes (New)\n" +
          "xxxxxxx"
      },
      message)
  end

  def test_create_mention_slack

    # ARRANGE
    url = "https://hooks.slack.com/services/xxxx/yyyy"
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    issue = Issue.find(1)
    old_assgined_to = nil
    new_assgined_to = User.find(2)
    note = "a" * 200
    author = User.find(1)

    RedmineIssueAssignNotice::MessageHelper.stubs(:mention_target).returns("user")

    # ACTION
    message = message_creator.create(issue, old_assgined_to, new_assgined_to, note, author)

    # ASSERT
    assert_equal(
      {
        :text => 
          "<@user> Assign changed from _[none]_ to _John Smith_\n" +
          "[eCookbook] <http://localhost:3000/issues/1|Bug #1> Cannot print recipes (New)\n" +
          "a" * 200
      },
      message)
  end

  def test_create_mention_teams

    # ARRANGE
    url = "https://examplecom.webhook.office.com/webhookb2/xxx/yyyy"
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    issue = Issue.find(1)
    old_assgined_to = nil
    new_assgined_to = User.find(2)
    note = "a"
    author = User.find(1)

    RedmineIssueAssignNotice::MessageHelper.stubs(:mention_target).returns("mentionId")

    # ACTION
    message = message_creator.create(issue, old_assgined_to, new_assgined_to, note, author)

    # ASSERT
    assert_equal(
      {
        :type => "message",
        :attachments => [
          {
            :contentType => "application/vnd.microsoft.card.adaptive",
            :content => {
              :type => "AdaptiveCard",
              :body => [
                {
                  :type => "TextBlock",
                  :text =>
                    "<at>John Smith</at> Assign changed from _[none]_ to _John Smith_  \n" +
                    "[eCookbook] [Bug #1](http://localhost:3000/issues/1) Cannot print recipes (New)  \n" +
                    "a",
                  :wrap => true
                }
              ],
              :$schema => "http://adaptivecards.io/schemas/adaptive-card.json",
              :version => "1.0",
              :msteams => {
                :width => "Full",
                :entities => [
                  {
                    :type => "mention",
                    :text => "<at>John Smith</at>",
                    :mentioned => {
                      :id => "mentionId",
                      :name => "John Smith"
                    }
                  }
                ]
              }
            }
          }
        ]
      },
      message)
  end

  def test_create_mention_googlechat

    # ARRANGE
    url = "https://chat.googleapis.com/v1/xxxx/yyyy"
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    issue = Issue.find(1)
    old_assgined_to = nil
    new_assgined_to = User.find(2)
    note = ""
    author = User.find(1)

    RedmineIssueAssignNotice::MessageHelper.stubs(:mention_target).returns("user")

    # ACTION
    message = message_creator.create(issue, old_assgined_to, new_assgined_to, note, author)

    # ASSERT
    assert_equal(
      {
        :text => 
          "<users/user> Assign changed from _[none]_ to _John Smith_\n" +
          "[eCookbook] <http://localhost:3000/issues/1|Bug #1> Cannot print recipes (New)\n"
      },
      message)
  end

  def test_create_mention_other

    # ARRANGE
    url = ""
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    issue = Issue.find(1)
    old_assgined_to = nil
    new_assgined_to = User.find(2)
    note = nil
    author = User.find(1)

    RedmineIssueAssignNotice::MessageHelper.stubs(:mention_target).returns("user")

    # ACTION
    message = message_creator.create(issue, old_assgined_to, new_assgined_to, note, author)

    # ASSERT
    assert_equal(
      {
        :text => 
          "@user Assign changed from _[none]_ to _John Smith_\n" +
          "[eCookbook] [Bug #1](http://localhost:3000/issues/1) Cannot print recipes (New)\n"
      },
      message)
  end

  def test_create_trimming

    # ARRANGE
    url = ""
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    issue = Issue.find(1)
    old_assgined_to = User.find(1)
    new_assgined_to = nil
    note = "a" * 201
    author = User.find(1)

    # ACTION
    message = message_creator.create(issue, old_assgined_to, new_assgined_to, note, author)

    # ASSERT
    assert_equal(
      {
        :text => 
          "Assign changed from _Redmine Admin_ to _[none]_\n" +
          "[eCookbook] [Bug #1](http://localhost:3000/issues/1) Cannot print recipes (New)\n" +
          ("a" * 200) + "..."
      },
      message)
  end
end
