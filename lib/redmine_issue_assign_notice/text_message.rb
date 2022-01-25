module RedmineIssueAssignNotice
  class TextMessage
    def initialize(formatter)
      @formatter = formatter
    end

    def create(issue, old_assgined_to, new_assgined_to, note, author)

      text = ""

      mention_to = MessageHelper.mention_target(new_assgined_to, author)
      if mention_to.present?
        text << @formatter.mention(mention_to)
        text << " "
      end

      text << "Assign changed from #{@formatter.user_name old_assgined_to} to #{@formatter.user_name new_assgined_to}"
      text << @formatter.change_line
      text << "[#{@formatter.escape issue.project}] "
      text << @formatter.link("#{issue.tracker} ##{issue.id}", MessageHelper.issue_url(issue))
      text << " #{@formatter.escape issue.subject} (#{@formatter.escape issue.status})"
      text << @formatter.change_line
      text << @formatter.trimming(note)

      return {:text => text}
    end
  end
end