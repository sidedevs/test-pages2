# frozen_string_literal: true

require "helper"
require "jekyll/commands/doctor"

class TestDoctorCommand < JekyllUnitTest
  context "URLs only differ by case" do
    setup do
      clear_dest
    end

    should "return success on a valid site/page" do
      @site = Site.new(Jekyll.configuration(
                         "source"      => File.join(source_dir, "/_urls_differ_by_case_valid"),
                         "destination" => dest_dir
                       ))
      @site.process
      output = capture_stderr do
        ret = Jekyll::Commands::Doctor.urls_only_differ_by_case(@site)
        refute ret
      end
      assert_equal "", output
    end

    # rubocop:disable Layout/LineLength
    should "return warning for pages only differing by case" do
      @site = Site.new(Jekyll.configuration(
                         "source"      => File.join(source_dir, "/_urls_differ_by_case_invalid"),
                         "destination" => dest_dir
                       ))
      @site.process
      output = capture_stderr do
        ret = Jekyll::Commands::Doctor.urls_only_differ_by_case(@site)
        assert ret
      end
      assert_includes output, "Warning: The following URLs only differ by case. On a case-" \
                              "insensitive file system one of the URLs will be overwritten by the " \
                              "other: #{dest_dir}/about/index.html, #{dest_dir}/About/index.html"
    end
    # rubocop:enable Layout/LineLength

    context "static files in a collection" do
      should "not trigger false positives" do
        @site = Site.new(Jekyll.configuration(
                           "source"      => source_dir,
                           "destination" => dest_dir,
                           "collections" => { "methods" => { "output" => true } }
                         ))
        @site.process
        output = capture_stderr do
          Jekyll::Commands::Doctor.conflicting_urls(@site)
        end
        refute_includes output, "extensionless_static_file"
      end
    end
  end
end
