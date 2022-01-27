require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/redmine_issue_assign_notice/formatter', __FILE__)

class FormatterTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @user = User.find(1)
  end

  def test_slack

    formatter = RedmineIssueAssignNotice::Formatter::Slack.new

    assert_equal "&lt;&gt;&amp;[]abc", formatter.escape("<>&[]abc")
    assert_equal "\n", formatter.change_line
    assert_equal "<http://example.com|[&lt;title&gt;]>", formatter.link("[<title>]", "http://example.com")
    assert_equal "<@xxx>", formatter.mention("xxx")
    assert_equal "_Redmine Admin_", formatter.user_name(@user)
    assert_equal "_[none]_", formatter.user_name(nil)
    assert_equal "_first last_", formatter.user_name("first_last")
  end

  def test_teams

    formatter = RedmineIssueAssignNotice::Formatter::Teams.new

    assert_equal "<>&[]abc", formatter.escape("<>&[]abc")
    assert_equal "  \n", formatter.change_line
    assert_equal "[ <title> ](http://example.com)", formatter.link("[<title>]", "http://example.com")
    assert_equal "@xxx", formatter.mention("xxx")
    assert_equal "_Redmine Admin_", formatter.user_name(@user)
    assert_equal "_[none]_", formatter.user_name(nil)
    assert_equal "_first last_", formatter.user_name("first_last")
  end

  def test_google_chat

    formatter = RedmineIssueAssignNotice::Formatter::GoogleChat.new

    assert_equal "&lt;&gt;&amp;[]abc", formatter.escape("<>&[]abc")
    assert_equal "\n", formatter.change_line
    assert_equal "<http://example.com|[&lt;title&gt;]>", formatter.link("[<title>]", "http://example.com")
    assert_equal "<users/xxx>", formatter.mention("xxx")
    assert_equal "_Redmine Admin_", formatter.user_name(@user)
    assert_equal "_[none]_", formatter.user_name(nil)
    assert_equal "_first last_", formatter.user_name("first_last")
  end

  def test_other

    formatter = RedmineIssueAssignNotice::Formatter::Other.new

    assert_equal "<>&[]abc", formatter.escape("<>&[]abc")
    assert_equal "\n", formatter.change_line
    assert_equal "[ <title> ](http://example.com)", formatter.link("[<title>]", "http://example.com")
    assert_equal "@xxx", formatter.mention("xxx")
    assert_equal "_Redmine Admin_", formatter.user_name(@user)
    assert_equal "_[none]_", formatter.user_name(nil)
    assert_equal "_first last_", formatter.user_name("first_last")
  end
end
