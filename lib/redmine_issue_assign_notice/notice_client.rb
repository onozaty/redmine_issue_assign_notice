require 'httpclient'
require 'uri'

module RedmineIssueAssignNotice
  class NoticeClient
    def notice(message, url)

      host = webhook_host(url)
      Rails.logger.debug "[RedmineIssueAssignNotice] NoticeClient#notice host:#{host}"

      begin
        client = HTTPClient.new
        client.ssl_config.cert_store.set_default_paths
        client.ssl_config.ssl_version = :auto
        conn = client.post_async url, message.to_json, {'Content-Type' => 'application/json; charset=UTF-8'}

        Thread.new do
          begin
            res = conn.pop
            if !HTTP::Status.successful?(res.status) 
              Rails.logger.warn("[RedmineIssueAssignNotice] Failed request to #{host} status:#{res.status}")
              return
            end

            Rails.logger.debug "[RedmineIssueAssignNotice] NoticeClient#notice success"

          rescue Exception => e
            Rails.logger.warn("[RedmineIssueAssignNotice] Failed request to #{host} error:#{e.class}")
          end
        end

      rescue Exception => e
        Rails.logger.warn("[RedmineIssueAssignNotice] Failed request to #{host} error:#{e.class}")
      end
    end

    private

    def webhook_host(url)
      URI.parse(url).host
    rescue URI::InvalidURIError
      nil
    end
  end
end
