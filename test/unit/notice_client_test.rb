require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/redmine_issue_assign_notice/notice_client', __FILE__)

class NoticeClientTest < ActiveSupport::TestCase
  def test_notice_does_not_log_webhook_query_parameters
    client = RedmineIssueAssignNotice::NoticeClient.new
    url =
      "https://defaultxxxxxxxx.e3.environment.api.powerplatform.com:443/" \
      "powerautomate/automations/direct/cu/10/workflows/xxxxxxxx/" \
      "triggers/manual/paths/invoke?api-version=1&sig=dummy"

    Rails.logger.expects(:debug).with(
      "[RedmineIssueAssignNotice] NoticeClient#notice " \
      "host:defaultxxxxxxxx.e3.environment.api.powerplatform.com")
    HTTPClient.expects(:new).raises(StandardError.new("request failed: #{url}"))
    Rails.logger.expects(:warn).with(
      "[RedmineIssueAssignNotice] Failed request to " \
      "defaultxxxxxxxx.e3.environment.api.powerplatform.com " \
      "error:StandardError")

    client.notice({}, url)
  end

  def test_webhook_host_does_not_include_query_parameters
    client = RedmineIssueAssignNotice::NoticeClient.new
    url =
      "https://defaultxxxxxxxx.e3.environment.api.powerplatform.com:443/" \
      "powerautomate/automations/direct/cu/10/workflows/xxxxxxxx/" \
      "triggers/manual/paths/invoke?api-version=1&sig=dummy"

    host = client.send(:webhook_host, url)

    assert_equal(
      "defaultxxxxxxxx.e3.environment.api.powerplatform.com",
      host)
  end

  def test_webhook_host_returns_nil_for_invalid_url
    client = RedmineIssueAssignNotice::NoticeClient.new

    host = client.send(:webhook_host, "invalid url")

    assert_nil(host)
  end
end
