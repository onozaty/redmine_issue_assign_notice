module RedmineIssueAssignNotice
  module MessageCreator

    def from(url)
      if url.include? 'slack.com/'
        return TextMessageCreator.new(Formatter::Slack.new)
      end
  
      if url.include? 'office.com/'
        return AdaptiveCardCreator.new
      end

      if url.include? 'googleapis.com/'
        return TextMessageCreator.new(Formatter::GoogleChat.new)
      end

      return TextMessageCreator.new(Formatter::Other.new)
    end

    module_function :from

    class TextMessageCreator
      def initialize(formatter)
        @formatter = formatter
      end
  
      def create(issue, old_assgined_to, new_assgined_to, note, author)
  
        text = ""
  
        mention_id = MessageHelper.mention_target(new_assgined_to, author)
        if mention_id.present?
          text << @formatter.mention(mention_id)
          text << " "
        end
  
        text << "Assign changed from #{@formatter.user_name old_assgined_to} to #{@formatter.user_name new_assgined_to}"
        text << @formatter.change_line
        text << "[#{@formatter.escape issue.project}] "
        text << @formatter.link("#{issue.tracker} ##{issue.id}", MessageHelper.issue_url(issue))
        text << " #{@formatter.escape issue.subject} (#{@formatter.escape issue.status})"
        text << @formatter.change_line
        text << @formatter.escape(MessageHelper.trimming(note))
  
        return {:text => text}
      end
    end

    class AdaptiveCardCreator
      def initialize()
        @formatter = Formatter::Teams.new
      end
  
      def create(issue, old_assgined_to, new_assgined_to, note, author)
  
        text = ""

        mention_id = MessageHelper.mention_target(new_assgined_to, author)
        if mention_id.present?
          mention_part = "<at>#{new_assgined_to}</at>"
          text << mention_part + " "
        end

        text << "Assign changed from #{@formatter.user_name old_assgined_to} to #{@formatter.user_name new_assgined_to}"
        text << @formatter.change_line
        text << "[#{@formatter.escape issue.project}] "
        text << @formatter.link("#{issue.tracker} ##{issue.id}", MessageHelper.issue_url(issue))
        text << " #{@formatter.escape issue.subject} (#{@formatter.escape issue.status})"
        text << @formatter.change_line
        text << @formatter.escape(MessageHelper.trimming(note))

        mention_entities = []
        if mention_id.present?
          mention_entities.push(
            { 
              :type => "mention",
              :text => mention_part,
              :mentioned => { 
                :id => mention_id,
                :name => new_assgined_to.to_s
              }
            }
          )
        end

        return {
          :type => "message",
          :attachments => [
            {
              :contentType => "application/vnd.microsoft.card.adaptive",
              :content => {
                :type => "AdaptiveCard",
                :body => [
                  {
                    :type => "TextBlock",
                    :text => text,
                    :wrap => true
                  }
                ],
                :$schema => "http://adaptivecards.io/schemas/adaptive-card.json",
                :version => "1.0",
                :msteams => {
                  :width => "Full",
                  :entities => mention_entities
                }
              }
            }
          ] 
        }
      end
    end
  end
end
