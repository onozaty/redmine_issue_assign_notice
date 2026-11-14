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

      # Redmine moves the details of a journal with private notes into a separate journal,
      # so the assignment change is taken from the issue instead of the journal.
      if not issue.saved_change_to_assigned_to_id?
        return
      end

      old_assgined_to = Principal.find_by_id(issue.assigned_to_id_before_last_save)
      new_assgined_to = issue.assigned_to

      note = journal.private_notes? ? '' : journal.notes

      notice(issue, old_assgined_to, new_assgined_to, note, journal.user)
    end

    private

    def notice(issue, old_assgined_to, new_assgined_to, note, author)

      if issue.is_private?
        return
      end

      if Setting.plugin_redmine_issue_assign_notice['notice_url_each_project'] == '1'
        notice_url_field = issue.project.custom_field_values.find{ |field| field.custom_field.name == 'Assign Notice URL' }
        notice_url = notice_url_field.value unless notice_url_field.nil?
      else
        notice_url = Setting.plugin_redmine_issue_assign_notice['notice_url']
      end

      note = '' if Setting.plugin_redmine_issue_assign_notice['disable_sending_content'] == '1'

      if notice_url.blank?
        return
      end

      message_creator = MessageCreator.from(notice_url)

      message = message_creator.create(issue, old_assgined_to, new_assgined_to, note, author)

      Rails.logger.debug "[RedmineIssueAssignNotice] IssueHookListener#notice message:#{message}"

      @client.notice(message, notice_url)
    end

  end
end
