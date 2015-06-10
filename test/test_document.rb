require 'helper'

class TestDocument < JekyllUnitTest
  context "a document in a collection" do
    setup do
      @site = fixture_site({
        "collections" => ["methods"]
      })
      @site.process
      @document = @site.collections["methods"].docs.first
    end

    should "exist" do
      assert !@document.nil?
    end

    should "know its relative path" do
      assert_equal "_methods/configuration.md", @document.relative_path
    end

    should "knows its extname" do
      assert_equal ".md", @document.extname
    end

    should "know its basename" do
      assert_equal "configuration.md", @document.basename
    end

    should "know its basename without extname" do
      assert_equal "configuration", @document.basename_without_ext
    end

    should "know whether its a yaml file" do
      assert_equal false, @document.yaml_file?
    end

    should "know its data" do
      assert_equal({
        "title" => "Jekyll.configuration",
        "whatever" => "foo.bar"
      }, @document.data)
    end

    context "with YAML ending in three dots" do
      setup do
        @site = fixture_site({
          "collections" => ["methods"],
        })
        @site.process
        @document = @site.collections["methods"].docs.last
      end

      should "know its data" do
        assert_equal({
          "title" => "YAML with Dots",
          "whatever" => "foo.bar"
        }, @document.data)
      end
    end

    should "output the collection name in the #to_liquid method" do
      assert_equal @document.to_liquid['collection'], "methods"
    end

    should "output its relative path as path in Liquid" do
      assert_equal @document.to_liquid['path'], "_methods/configuration.md"
    end
  end

  context "a document as part of a collection with frontmatter defaults" do
    setup do
      @site = fixture_site({
        "collections" => ["slides"],
        "defaults" => [{
          "scope" => { "path" => "", "type" => "slides" },
          "values" => {
            "nested" => {
              "key" => "myval",
            }
          }
        }]
      })
      @site.process
      @document = @site.collections["slides"].docs.find{ |d| d.is_a?(Document) }
    end

    should "know the frontmatter defaults" do
      assert_equal({
        "title" => "Example slide",
        "layout" => "slide",
        "nested" => {
          "key" => "myval"
        }
      }, @document.data)
    end
  end

  context "a document as part of a collection with overriden default values" do
    setup do
      @site = fixture_site({
        "collections" => ["slides"],
        "defaults" => [{
          "scope" => { "path" => "", "type" => "slides" },
          "values" => {
            "nested" => {
              "test1" => "default1",
              "test2" => "default1"
            }
          }
        }]
      })
      @site.process
      @document = @site.collections["slides"].docs[1]
    end

    should "override default values in the document frontmatter" do
      assert_equal({
        "title" => "Override title",
        "layout" => "slide",
        "nested" => {
          "test1" => "override1",
          "test2" => "override2"
        }
      }, @document.data)
    end
  end

  context "a document as part of a collection with valid path" do
    setup do
      @site = fixture_site({
        "collections" => ["slides"],
        "defaults" => [{
          "scope" => { "path" => "slides", "type" => "slides" },
          "values" => {
            "nested" => {
              "key" => "value123",
            }
          }
        }]
      })
      @site.process
      @document = @site.collections["slides"].docs.first
    end

    should "know the frontmatter defaults" do
      assert_equal({
        "title" => "Example slide",
        "layout" => "slide",
        "nested" => {
          "key" => "value123"
        }
      }, @document.data)
    end
  end

  context "a document as part of a collection with invalid path" do
    setup do
      @site = fixture_site({
        "collections" => ["slides"],
        "defaults" => [{
          "scope" => { "path" => "somepath", "type" => "slides" },
          "values" => {
            "nested" => {
              "key" => "myval",
            }
          }
        }]
      })
      @site.process
      @document = @site.collections["slides"].docs.first
    end

    should "not know the specified frontmatter defaults" do
      assert_equal({
        "title" => "Example slide",
        "layout" => "slide"
      }, @document.data)
    end
  end

  context "a document in a collection with a custom permalink" do
    setup do
      @site = fixture_site({
        "collections" => ["slides"]
      })
      @site.process
      @document = @site.collections["slides"].docs[2]
      @dest_file = dest_dir("slide/3/index.html")
    end

    should "know its permalink" do
      assert_equal "/slide/3/", @document.permalink
    end

    should "produce the right URL" do
      assert_equal "/slide/3/", @document.url
    end
  end

  context "a document in a collection with custom filename permalinks" do
    setup do
      @site = fixture_site({
        "collections" => {
          "slides" => {
            "output"    => true,
            "permalink" => "/slides/test/:name"
          }
        },
      })
      @site.process
      @document = @site.collections["slides"].docs[0]
      @dest_file = dest_dir("slides/test/example-slide-1.html")
    end

    should "produce the right URL" do
      assert_equal "/slides/test/example-slide-1", @document.url
    end

    should "produce the right destination file" do
      assert_equal @dest_file, @document.destination(dest_dir)
    end
  end

  context "a document in a collection with pretty permalink style" do
    setup do
      @site = fixture_site({
        "collections" => {
          "slides" => {
            "output"    => true,
          }
        },
      })
      @site.permalink_style = :pretty
      @site.process
      @document = @site.collections["slides"].docs[0]
      @dest_file = dest_dir("slides/example-slide-1/index.html")
    end

    should "produce the right URL" do
      assert_equal "/slides/example-slide-1/", @document.url
    end

    should "produce the right destination file" do
      assert_equal @dest_file, @document.destination(dest_dir)
    end
  end

  context "documents in a collection with custom title permalinks" do
    setup do
      @site = fixture_site({
        "collections" => {
          "slides" => {
            "output"    => true,
            "permalink" => "/slides/:title"
          }
        },
      })
      @site.process
      @document = @site.collections["slides"].docs[3]
      @document_without_slug = @site.collections["slides"].docs[4]
      @document_with_strange_slug = @site.collections["slides"].docs[5]
    end

    should "produce the right URL if they have a slug" do
      assert_equal "/slides/so-what-is-jekyll-exactly", @document.url
    end
    should "produce the right destination file if they have a slug" do
      dest_file = dest_dir("slides/so-what-is-jekyll-exactly.html")
      assert_equal dest_file, @document.destination(dest_dir)
    end

    should "produce the right URL if they don't have a slug" do
      assert_equal "/slides/example-slide-5", @document_without_slug.url
    end
    should "produce the right destination file if they don't have a slug" do
      dest_file = dest_dir("slides/example-slide-5.html")
      assert_equal dest_file, @document_without_slug.destination(dest_dir)
    end

    should "produce the right URL if they have a wild slug" do
      assert_equal "/slides/well-so-what-is-jekyll-then", @document_with_strange_slug.url
    end
    should "produce the right destination file if they have a wild slug" do
      dest_file = dest_dir("/slides/well-so-what-is-jekyll-then.html")
      assert_equal dest_file, @document_with_strange_slug.destination(dest_dir)
    end
  end

  context "documents in a collection" do
    setup do
      @site = fixture_site({
        "collections" => {
          "slides" => {
            "output" => true
          }
        },
      })
      @site.process
      @files = @site.collections["slides"].docs
    end

    context "without output overrides" do
      should "be output according to collection defaults" do
        refute_nil @files.find { |doc| doc.relative_path == "_slides/example-slide-4.html" }
      end
    end

    context "with output overrides" do
      should "be output according its front matter" do
        assert_nil @files.find { |doc| doc.relative_path == "_slides/non-outputted-slide.html" }
      end
    end
  end

  context "a static file in a collection" do
    setup do
      @site = fixture_site({
        "collections" => {
          "slides" => {
            "output" => true
          }
        }
      })
      @site.process
      @document = @site.collections["slides"].files.find { |doc| doc.relative_path == "_slides/octojekyll.png" }
      @dest_file = dest_dir("slides/octojekyll.png")
    end

    should "be a static file" do
      assert_equal true, @document.is_a?(StaticFile)
    end

    should "be set to write" do
      assert @document.write?
    end

    should "be in the list of docs_to_write" do
      assert @site.docs_to_write.include?(@document)
    end

    should "be output in the correct place" do
      assert_equal true, File.file?(@dest_file)
    end
  end

  context "a document in a collection with non-alphabetic file name" do
    setup do
      @site = fixture_site({
        "collections" => {
          "methods" => {
            "output" => true
          }
        },
      })
      @site.process
      @document = @site.collections["methods"].docs.find { |doc| doc.relative_path == "_methods/escape-+ #%20[].md" }
      @dest_file = dest_dir("methods/escape-+ #%20[].html")
    end

    should "produce the right URL" do
      assert_equal "/methods/escape-+%20%23%2520%5B%5D.html", @document.url
    end

    should "produce the right destination" do
      assert_equal @dest_file, @document.destination(dest_dir)
    end

    should "be output in the correct place" do
      assert_equal true, File.file?(@dest_file)
    end
  end
end
