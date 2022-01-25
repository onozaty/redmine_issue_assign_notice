module RedmineIssueAssignNotice

  class IssueHookListener < Redmine::Hook::Listener

    def initialize
      @client = NoticeClient.new
      Rails.logger.debug "[RedmineIssueAssignNotice] IssueHookListener#initialize"
    end

    def redmine_issue_assign_notice_new(context={})
      issue = context[:issue]

      Rails.logger.debug "[RedmineIssueAssignNotice] IssueHookListener#redmine_issue_assign_notice_new issue_id:#{issue.id}"

      if issue.assigned_to.nil? 
        return
      end

      notice(issue, nil, issue.assigned_to, issue.description, issue.author)
    end

    def redmine_issue_assign_notice_change(context={})
      issue = context[:issue]
      journal = context[:journal]

      Rails.logger.debug "[RedmineIssueAssignNotice] IssueHookListener#redmine_issue_assign_notice_change issue_id:#{issue.id}"

      assign_journal = journal.details.find{ |detail| detail.property == 'attr' && detail.prop_key == 'assigned_to_id' }
      if assign_journal.nil? 
        return
      end

      old_assgined_to = Principal.find_by_id(assign_journal.old_value.to_i) unless assign_journal.old_value.nil?
      new_assgined_to = Principal.find_by_id(assign_journal.value.to_i) unless assign_journal.value.nil?

      notice(issue, old_assgined_to, new_assgined_to, journal.notes, journal.user)
    end

    private

    def notice(issue, old_assgined_to, new_assgined_to, note, author)

      if Setting.plugin_redmine_issue_assign_notice['notice_url_each_project'] == '1'
        notice_url_field = issue.project.custom_field_values.find{ |field| field.custom_field.name == 'Assign Notice URL' }
        notice_url = notice_url_field.value unless notice_url_field.nil?
      else
        notice_url = Setting.plugin_redmine_issue_assign_notice['notice_url']
      end

      if notice_url.blank?
        return
      end

      formatter = RedmineIssueAssignNotice::Formatter.create notice_url
      textMessage = TextMessage.new(formatter)

      message = textMessage.create(issue, old_assgined_to, new_assgined_to, note, author)

      Rails.logger.debug "[RedmineIssueAssignNotice] IssueHookListener#notice message:#{message}"

      @client.notice(message, notice_url)
    end

  end
end
