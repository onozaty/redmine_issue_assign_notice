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
            :contentUrl => nil,
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

  def test_workflows_webhook_uses_adaptive_card_creator

    # ARRANGE
    url =
      "https://defaultxxxxxxxx.e3.environment.api.powerplatform.com:443/" \
      "powerautomate/automations/direct/cu/10/workflows/xxxxxxxx/" \
      "triggers/manual/paths/invoke" \
      "?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=dummy"

    # ACTION
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    # ASSERT
    assert_instance_of(
      RedmineIssueAssignNotice::MessageCreator::AdaptiveCardCreator,
      message_creator)
  end

  def test_legacy_outlook_teams_webhook_uses_adaptive_card_creator

    # ARRANGE
    url = "https://outlook.office.com/webhook/xxxx/yyyy"

    # ACTION
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    # ASSERT
    assert_instance_of(
      RedmineIssueAssignNotice::MessageCreator::AdaptiveCardCreator,
      message_creator)
  end

  def test_create_mention_teams_channel_workflows

    # ARRANGE
    url =
      "https://defaultxxxxxxxx.e3.environment.api.powerplatform.com:443/" \
      "powerautomate/automations/direct/cu/10/workflows/xxxxxxxx/" \
      "triggers/manual/paths/invoke" \
      "?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=dummy"
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
    assert_equal("message", message[:type])
    assert_equal(
      "application/vnd.microsoft.card.adaptive",
      message[:attachments][0][:contentType])
    assert_nil(message[:attachments][0][:contentUrl])
    assert_equal("1.0", message[:attachments][0][:content][:version])
    assert_equal(
      [
        {
          :type => "mention",
          :text => "<at>John Smith</at>",
          :mentioned => {
            :id => "mentionId",
            :name => "John Smith"
          }
        }
      ],
      message[:attachments][0][:content][:msteams][:entities])
  end

  def test_create_teams_channel_workflows_without_mention

    # ARRANGE
    url =
      "https://defaultxxxxxxxx.e3.environment.api.powerplatform.com:443/" \
      "powerautomate/automations/direct/cu/10/workflows/xxxxxxxx/" \
      "triggers/manual/paths/invoke" \
      "?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=dummy"
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    issue = Issue.find(1)
    old_assgined_to = nil
    new_assgined_to = User.find(2)
    note = "a"
    author = User.find(1)

    RedmineIssueAssignNotice::MessageHelper.stubs(:mention_target).returns(nil)

    # ACTION
    message = message_creator.create(issue, old_assgined_to, new_assgined_to, note, author)

    # ASSERT
    assert_equal("message", message[:type])
    assert_equal(1, message[:attachments].length)

    attachment = message[:attachments][0]
    assert_equal(
      "application/vnd.microsoft.card.adaptive",
      attachment[:contentType])
    assert_nil(attachment[:contentUrl])
    assert_equal("AdaptiveCard", attachment[:content][:type])
    assert_equal("1.0", attachment[:content][:version])
    assert_equal(
      "http://adaptivecards.io/schemas/adaptive-card.json",
      attachment[:content][:$schema])
    assert_equal("TextBlock", attachment[:content][:body][0][:type])
    assert_equal(true, attachment[:content][:body][0][:wrap])
    assert_match(/Cannot print recipes/, attachment[:content][:body][0][:text])
    assert_equal([], attachment[:content][:msteams][:entities])
  end

  def test_teams_domain_in_query_string_is_not_recognized

    # ARRANGE
    url = "https://example.com/webhook?redirect=environment.api.powerplatform.com"

    # ACTION
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    # ASSERT
    assert_instance_of(
      RedmineIssueAssignNotice::MessageCreator::TextMessageCreator,
      message_creator)
  end

  def test_invalid_url_uses_text_message_creator

    # ARRANGE
    url = "invalid url"

    # ACTION
    message_creator = RedmineIssueAssignNotice::MessageCreator.from(url)

    # ASSERT
    assert_instance_of(
      RedmineIssueAssignNotice::MessageCreator::TextMessageCreator,
      message_creator)
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
