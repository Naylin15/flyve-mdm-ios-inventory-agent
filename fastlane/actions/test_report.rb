require 'fastlane/action'
require_relative '../helper/test_report_helper'
require "erb"
require "rexml/document"

module Fastlane
  module Actions
    class TestReportAction < Action
      def self.run(params)
        UI.message("The test_report plugin is working!")

        include REXML

        File.rename("fastlane/test_output/report.junit", "fastlane/test_output/report.xml")

        file = File.new(File.expand_path(params[:report_path]))
        doc = Document.new(file)

        template = File.new(File.expand_path(params[:template_path]))

        result = ERB.new(template).result(binding())

        open('fastlane/test_output/index.html', 'w') do |f|
          f.puts result
        end

      end

      def self.description
        "Create customized HTML template for test reports"
      end

      def self.authors
        ["Naylin Medina"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Create HTML for test reports"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                  env_name: "TEST_REPORT_PATH",
                               description: "Path to the test report",
                             default_value: './fastlane/test_output/report.xml'),
          FastlaneCore::ConfigItem.new(key: :template_path,
                                  env_name: "TEMPLATE_PATH",
                               description: "Path to template",
                                 is_string: true,
                                  optional: false)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
