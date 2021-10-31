# frozen_string_literal: true

require "helper"

class TestSnippet < JekyllUnitTest
  def rendered_site(site)
    site.read
    site.render
    site
  end

  context "A snippet" do
    setup do
      @site = rendered_site(fixture_site)
    end

    should "be renderable without front matter" do
      assert_equal(
        %(<h2 id="hello-world">Hello World</h2>),
        @site.snippets["lipsum/lorem.md"].output.strip
      )
    end

    should "ignore front matter" do
      snippet = @site.snippets["front_matter.md"]
      assert_empty snippet.data
      assert_includes snippet.content, "title: Foo"
    end

    should "not have a URL" do
      assert_raises(NoMethodError) { @site.snippets["lipsum/lorem.md"].url }
    end

    context "within a themed-site" do
      setup do
        @themed_site = rendered_site(fixture_site("theme" => "test-theme"))
      end

      should "be renderable without front matter" do
        assert_equal(
          %(<h2 id="markdown-within-theme-gem">Markdown within theme-gem</h2>),
          @themed_site.snippets["kappa/alpha.md"].output.strip
        )
      end
    end
  end
end
