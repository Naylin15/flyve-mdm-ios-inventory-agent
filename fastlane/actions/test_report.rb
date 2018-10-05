require 'fastlane/action'
#require_relative '../helper/test_report_helper'
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

        template = '---
layout: testReport
---
                        
                        <div class="total row">
                        <h2 class="col-sm-18">Test Results</h2>
                        <h2 class="col-sm-6 text-right"><%= doc.root.attributes["tests"] %> tests</h2>
                    </div>
                    <div>
                    <% i = 0 %>
                        <% doc.elements.each("testsuites/testsuite") do |name| %>
                            <% i = i + 1 %>
                            <% if name.attributes["failures"] == "0" %>
                        <div class="test-suite row test-suite--passing" onclick="changeDisplay(<%= "\'#test-#{i}\'"%>)">
                            <% else %>
                        <div class="test-suite row test-suite--failing" onclick="changeDisplay(<%= "\'#test-#{i}\'"%>)">
                            <% end %>
                            <h4 class="col-sm-20"><%= name.attributes["name"] %></h4>
                            <h4 class="col-sm-4 text-right"><%= name.attributes["tests"] %> tests</h4>
                        </div>
                        <!-- Failing or passing class -->
                        <div id="<%= "test-#{i}"%>">
                         
                            <% doc.elements.each("testsuites/testsuite/testcase") do |test| %>
                                <% if test.attributes["classname"] == name.attributes["name"] %>
                                    
                                    <% if test.attributes["time"] == nil %>
                                <div class="test-case--failing row">
                                 <div class="col-sm-16">
                                     <p><%= test.attributes["name"] %></p>
                                 </div>
                                 <div class="col-sm-4">
                                     <p><%= test.elements["failure"].attributes["message"] %></p>
                                 </div>
                                 <div class="col-sm-4 text-right">
                                     <p><%= test.elements["failure"].text %></p>
                                 </div>
                                </div>
                                    <% else %>
                                <div class="test-case--passing row">
                                 <div class="col-sm-20">
                                     <p><%= test.attributes["name"] %></p>
                                 </div>
                                 <div class="col-sm-4 text-right">
                                     <p><%= test.attributes["time"] %></p>
                                 </div>
                                </div>
                                    <% end %>
                                <% end %>
                            <% end %>
                        </div>
                         <% end %>
                
                    </div>'

        result = ERB.new(template).result(binding())

        open('./fastlane/test_output/index.html', 'w') do |f|
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
          FastlaneCore::ConfigItem.new(key: :report_path,
                                  env_name: "TEST_REPORT_PATH",
                               description: "Path to the test report",
                             default_value: './fastlane/test_output/report.xml')
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
