module RedmineIssueAssignNotice

  class IssueHookListener < Redmine::Hook::Listener

    def initialize
      @client = NoticeClient.new
      Rails.logger.debug "IssueHookListener#initialize"
    end

    def redmine_issue_assign_notice_new(context={})
      issue = context[:issue]

      Rails.logger.debug "IssueHookListener#redmine_issue_assign_notice_new issue_id:#{issue.id}"

      if issue.assigned_to.nil? 
        return
      end

      notice(issue: issue, new_assgined_to: issue.assigned_to)
    end

    def redmine_issue_assign_notice_change(context={})
      issue = context[:issue]
      journal = context[:journal]

      Rails.logger.debug "IssueHookListener#redmine_issue_assign_notice_change issue_id:#{issue.id}"

      assign_journal = journal.details.find{ |detail| detail.property == 'attr' && detail.prop_key == 'assigned_to_id' }
      if assign_journal.nil? 
        return
      end

      old_assgined_to = User.find(assign_journal.old_value.to_i) unless assign_journal.old_value.nil?
      new_assgined_to = User.find(assign_journal.value.to_i) unless assign_journal.value.nil?

      notice(issue: issue, old_assgined_to: old_assgined_to, new_assgined_to: new_assgined_to)
    end

    private

    def notice(issue:, old_assgined_to: nil, new_assgined_to:)
      message = create_message(issue, old_assgined_to, new_assgined_to)

      Rails.logger.debug "IssueHookListener#notice message:#{message}"

      @client.notice(message, Setting.plugin_redmine_issue_assign_notice['notice_url'])
    end

    def create_message(issue, old_assgined_to, new_assgined_to)
      "[#{escape issue.project}] (#{escape issue.status}) <#{issue_url issue}|#{escape issue}>\n" +
        "#{old_assgined_to.nil? ? nil : (escape old_assgined_to) } => #{new_assgined_to.nil? ? nil : (escape new_assgined_to) }"
    end

    def issue_url(issue)
      "#{Setting.protocol}://#{Setting.host_name}/issues/#{issue.id}"
    end

    def escape(msg)
		  msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
  	end
  end
end
