module RedmineIssueAssignNotice
  class MessageHelper
    def mention_target(assgined_to, author)

      if assgined_to.nil? ||
         Setting.plugin_redmine_issue_assign_notice['mention_to_assignee'] != '1' ||
         assgined_to == author

         return nil
      end

      noteice_field = assgined_to.custom_field_values.find{ |field| field.custom_field.name == 'Assign Notice ID' }
      if noteice_field.nil? || noteice_field.value.blank?
        return nil
      end

      noteice_field.value
    end

    def issue_url(issue)
      "#{Setting.protocol}://#{Setting.host_name}/issues/#{issue.id}"
    end
  end
end