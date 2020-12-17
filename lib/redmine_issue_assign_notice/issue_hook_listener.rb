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

      notice(issue, nil, issue.assigned_to, issue.description, issue.author)
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

      message = create_message(issue, old_assgined_to, new_assgined_to, note, author, notice_url)

      Rails.logger.debug "IssueHookListener#notice message:#{message}"

      @client.notice(message, notice_url)
    end

    def create_message(issue, old_assgined_to, new_assgined_to, note, author, notice_url)

      message = "#{mention(new_assgined_to, author, notice_url)}"
      message << " " if message.length > 0
      message << "Assign changed from #{user_name old_assgined_to} to #{user_name new_assgined_to}"
      message << "\n"
      message << "\n" if teams?(notice_url)
      message << "[#{escape issue.project}] "
      if teams?(notice_url)
        message << "[#{escape issue.tracker} ##{issue.id}](#{issue_url issue}) "
      else
        message << "<#{issue_url issue}|#{escape issue.tracker} ##{issue.id}> "
      end
      message << "#{escape issue.subject} (#{escape issue.status})"
      message << "\n"
      message << "\n" if teams?(notice_url)
      message << "\n"
      message << "\n" if teams?(notice_url)
      message << trimming(note)
    end

    def mention(assgined_to, author, notice_url)

      if assgined_to.nil? ||
         Setting.plugin_redmine_issue_assign_notice['mention_to_assignee'] != '1' ||
         assgined_to == author

         return nil
      end

      noteice_field = assgined_to.custom_field_values.find{ |field| field.custom_field.name == 'Assign Notice ID' }
      if noteice_field.nil? || noteice_field.value.blank?
        return nil
      end

      if slack?(notice_url)
        "<@#{noteice_field.value}>"
      else
        "@#{noteice_field.value}"
      end
    end

    def user_name(user)
      if user.nil?
        '_[none]_'
      else
        "_#{escape user}_"
      end
    end

    def issue_url(issue)
      "#{Setting.protocol}://#{Setting.host_name}/issues/#{issue.id}"
    end

    def escape(msg)
      msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("[", "\\[").gsub("]", "\\]")
    end

    def trimming(note)
      if note.nil?
        return nil
      end

      flat = note.gsub(/\r\n|\n|\r/, ' ')
      if flat.length > 200
        flat[0, 200] + '...'
      else
        flat
      end
    end

    def slack?(notice_url)
      notice_url.include? 'slack.com/'
    end

    def teams?(notice_url)
      notice_url.include? 'office.com/'
    end
  end
end
