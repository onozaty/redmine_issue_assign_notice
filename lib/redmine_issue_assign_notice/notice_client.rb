require 'httpclient'

module RedmineIssueAssignNotice
  class NoticeClient
    def notice(message, url)

      Rails.logger.debug "[RedmineIssueAssignNotice] NoticeClient#notice url:#{url}"

      begin
        client = HTTPClient.new
        client.ssl_config.cert_store.set_default_paths
        client.ssl_config.ssl_version = :auto
        res = client.post url, message.to_json, {'Content-Type' => 'application/json; charset=UTF-8'}

        if !HTTP::Status.successful?(res.status) 
          Rails.logger.warn("[RedmineIssueAssignNotice] Failed request to #{url}")
          Rails.logger.warn(res.inspect)
          return
        end

        Rails.logger.debug "[RedmineIssueAssignNotice] NoticeClient#notice success"

      rescue Exception => e
        Rails.logger.warn("[RedmineIssueAssignNotice] Failed request to #{url}")
        Rails.logger.warn(e.inspect)
      end
    end
  end
end
