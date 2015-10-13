module Fastlane
  module Actions
    class JekyllAction < Action
      def self.run(params)
        Actions.verify_gem!('jekyll')
        cmd = []

        cmd << ['bundle exec'] if File.exist?('Gemfile')
        cmd << ['jekyll']
        cmd << params[:command]

        Actions.sh(cmd.join(' '))
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "jekyll wrapper for fastlane"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :command,
                                       env_name: "FL_JEKYLL_COMMAND",
                                       description: "The command you want jekyll to execute",
                                       optional: true,
                                       is_string: true,
                                       default_value: 'build'),
        ]
      end

      def self.output
        [
          # no output
        ]
      end

      def self.return_value
      end

      def self.authors
        ["Liquidsoul"]
      end

      def self.is_supported?(platform)
        platform == :mac
      end
    end
  end
end
