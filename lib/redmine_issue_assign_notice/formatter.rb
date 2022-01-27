module RedmineIssueAssignNotice
  module Formatter

    class Slack
      def escape(msg)
        msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
      end

      def change_line
        "\n"
      end

      def link(title, url)
        "<#{url}|#{escape(title)}>"
      end

      def user_name(user)
        if user.nil?
          '_[none]_'
        else
          "_#{escape(user).gsub("_", " ")}_"
        end
      end

      def mention(id)
        "<@#{id}>"
      end
    end

    class Teams
      def escape(msg)
        msg.to_s
      end

      def change_line
        "  \n"
      end

      def link(title, url)
        "[#{escape(title).gsub("[", " ").gsub("]", " ")}](#{url})"
      end

      def user_name(user)
        if user.nil?
          '_[none]_'
        else
          "_#{escape(user).gsub("_", " ")}_"
        end
      end

      def mention(id)
        # Teams does not support text format mention.
        "@#{id}"
      end
    end

    class GoogleChat
      def escape(msg)
        msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
      end

      def change_line
        "\n"
      end

      def link(title, url)
        "<#{url}|#{escape(title)}>"
      end

      def user_name(user)
        if user.nil?
          '_[none]_'
        else
          "_#{escape(user).gsub("_", " ")}_"
        end
      end

      def mention(id)
        "<users/#{id}>"
      end
    end

    class Other
      def escape(msg)
        msg.to_s
      end

      def change_line
        "\n"
      end

      def link(title, url)
        "[#{escape(title).gsub("[", " ").gsub("]", " ")}](#{url})"
      end

      def user_name(user)
        if user.nil?
          '_[none]_'
        else
          "_#{escape(user).gsub("_", " ")}_"
        end
      end

      def mention(id)
        "@#{id}"
      end
    end

  end
end
