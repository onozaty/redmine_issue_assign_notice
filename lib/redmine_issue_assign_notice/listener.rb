class IssueHookListener < Redmine::Hook::Listener
    def redmine_issue_assign_notice_new(context={})
        issue = context[:issue]

        Rails.logger.debug "IssueHookListener#redmine_issue_assign_notice_new issue_id:#{issue.id}"
    end

    def redmine_issue_assign_notice_change(context={})
        issue = context[:issue]
        journal = context[:journal]

        Rails.logger.debug "IssueHookListener#redmine_issue_assign_notice_change issue_id:#{issue.id}"
    end
end