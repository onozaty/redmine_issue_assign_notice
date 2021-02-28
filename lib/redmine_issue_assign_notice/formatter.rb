module RedmineIssueAssignNotice
  module Formatter

    def create(url)
      if url.include? 'slack.com/'
        return Slack.new
      end
  
      if url.include? 'office.com/'
        return Teams.new
      end

      if url.include? 'googleapis.com/'
        return GoogleChat.new
      end

      Default.new
    end

    module_function :create

    class Default
      def escape(msg)
        msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
      end

      def change_line
        "\n"
      end

      def link(title, url)
        "<#{url}|#{escape title}>"
      end

      def mention(id)
        "@#{id}"
      end

      def user_name(user)
        if user.nil?
          '_[none]_'
        else
          "_#{escape user}_"
        end
      end

      def trimming(note)
        if note.nil?
          return ''
        end
  
        flat = note.gsub(/\r\n|\n|\r/, ' ')
        if flat.length > 200
          flat[0, 200] + '...'
        else
          flat
        end
      end
    end

    class Slack < Default
      def mention(id)
        "<@#{id}>"
      end
    end

    class Teams < Default
      def escape(msg)
        msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("[", "\\[").gsub("]", "\\]")
      end

      def change_line
        "  \n"
      end

      def link(title, url)
        "[#{escape title}](#{url})"
      end

      def mention(id)
        "@#{id}"
      end
    end

    class GoogleChat < Default
      def mention(id)
        "<users/#{id}>"
      end
    end
  end
end
