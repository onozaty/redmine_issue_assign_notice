require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/redmine_issue_assign_notice/formatter', __FILE__)

class FormatterTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @user = User.find(1)
  end

  def test_default

    formatter = RedmineIssueAssignNotice::Formatter.create ""

    assert_equal "&lt;&gt;&amp;[]abc", formatter.escape("<>&[]abc")
    assert_equal "\n", formatter.change_line
    assert_equal "<http://example.com|[&lt;title&gt;]>", formatter.link("[<title>]", "http://example.com")
    assert_equal "@xxx", formatter.mention("xxx")
    assert_equal "_Redmine Admin_", formatter.user_name(@user)
    assert_equal "_[none]_", formatter.user_name(nil)
    assert_equal "a b c d", formatter.trimming("a\nb\rc\r\nd")
    assert_equal "a" * 200, formatter.trimming("a" * 200)
    assert_equal ("a" * 200) + "...", formatter.trimming("a" * 201)
    assert_equal "", formatter.trimming(nil)
  end

  def test_slack

    formatter = RedmineIssueAssignNotice::Formatter.create "https://hooks.slack.com/services/xxxx/yyyy"

    assert_equal "&lt;&gt;&amp;[]abc", formatter.escape("<>&[]abc")
    assert_equal "\n", formatter.change_line
    assert_equal "<http://example.com|[&lt;title&gt;]>", formatter.link("[<title>]", "http://example.com")
    assert_equal "<@xxx>", formatter.mention("xxx")
    assert_equal "_Redmine Admin_", formatter.user_name(@user)
    assert_equal "_[none]_", formatter.user_name(nil)
    assert_equal "a b c d", formatter.trimming("a\nb\rc\r\nd")
    assert_equal "a" * 200, formatter.trimming("a" * 200)
    assert_equal ("a" * 200) + "...", formatter.trimming("a" * 201)
    assert_equal "", formatter.trimming(nil)
  end

  def test_teams

    formatter = RedmineIssueAssignNotice::Formatter.create "https://examplecom.webhook.office.com/webhookb2/xxx/yyyy"

    assert_equal "&lt;&gt;&amp;\\[\\]abc", formatter.escape("<>&[]abc")
    assert_equal "  \n", formatter.change_line
    assert_equal "[\\[&lt;title&gt;\\]](http://example.com)", formatter.link("[<title>]", "http://example.com")
    assert_equal "@xxx", formatter.mention("xxx")
    assert_equal "_Redmine Admin_", formatter.user_name(@user)
    assert_equal "_[none]_", formatter.user_name(nil)
    assert_equal "a b c d", formatter.trimming("a\nb\rc\r\nd")
    assert_equal "a" * 200, formatter.trimming("a" * 200)
    assert_equal ("a" * 200) + "...", formatter.trimming("a" * 201)
    assert_equal "", formatter.trimming(nil)
  end
end
