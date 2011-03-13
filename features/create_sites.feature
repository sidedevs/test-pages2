Feature: Create sites
  As a hacker who likes to blog
  I want to be able to make a static site
  In order to share my awesome ideas with the interwebs

  Scenario: Basic site
    Given I have an "index.html" file that contains "Basic Site"
    When I run jekyll
    Then the _site directory should exist
    And I should see "Basic Site" in "_site/index.html"

  Scenario: Basic site with a post
    Given I have a _posts directory
    And I have the following post:
      | title   | date      | content          |
      | Hackers | 3/27/2009 | My First Exploit |
    When I run jekyll
    Then the _site directory should exist
    And I should see "My First Exploit" in "_site/2009/03/27/hackers.html"

  Scenario: Basic site with layout and a page
    Given I have a _layouts directory
    And I have an "index.html" page with layout "default" that contains "Basic Site with Layout"
    And I have a default layout that contains "Page Layout: {{ content }}"
    When I run jekyll
    Then the _site directory should exist
    And I should see "Page Layout: Basic Site with Layout" in "_site/index.html"

  Scenario: Basic site with layout and a post
    Given I have a _layouts directory
    And I have a _posts directory
    And I have the following posts:
      | title    | date      | layout  | content                               |
      | Wargames | 3/27/2009 | default | The only winning move is not to play. |
    And I have a default layout that contains "Post Layout: {{ content }}"
    When I run jekyll
    Then the _site directory should exist
    And I should see "Post Layout: <p>The only winning move is not to play.</p>" in "_site/2009/03/27/wargames.html"

  Scenario: Basic site with layouts, pages, posts and files
    Given I have a _layouts directory
    And I have a page layout that contains "Page {{ page.title }}: {{ content }}"
    And I have a post layout that contains "Post {{ page.title }}: {{ content }}"
    And I have an "index.html" page with layout "page" that contains "Site contains {{ site.pages.size }} pages and {{ site.posts.size }} posts"
    And I have a blog directory
    And I have a "blog/index.html" page with layout "page" that contains "blog category index page"
    And I have an "about.html" file that contains "No replacement {{ site.posts.size }}"
    And I have an "another_file" file that contains ""
    And I have a _posts directory
    And I have the following posts:
      | title     | date      | layout  | content                                |
      | entry1    | 3/27/2009 | post    | content for entry1.                    |
      | entry2    | 4/27/2009 | post    | content for entry2.                    |
    And I have a category/_posts directory
    And I have the following posts in "category":
      | title     | date      | layout  | content                                |
      | entry3    | 5/27/2009 | post    | content for entry3.                    |
      | entry4    | 6/27/2009 | post    | content for entry4.                    |
    When I run jekyll
    Then the _site directory should exist
    And I should see "Page : Site contains 2 pages and 4 posts" in "_site/index.html"
    And I should see "No replacement \{\{ site.posts.size \}\}" in "_site/about.html"
    And I should see "" in "_site/another_file"
    And I should see "Page : blog category index page" in "_site/blog/index.html"
    And I should see "Post entry1: <p>content for entry1.</p>" in "_site/2009/03/27/entry1.html"
    And I should see "Post entry2: <p>content for entry2.</p>" in "_site/2009/04/27/entry2.html"
    And I should see "Post entry3: <p>content for entry3.</p>" in "_site/category/2009/05/27/entry3.html"
    And I should see "Post entry4: <p>content for entry4.</p>" in "_site/category/2009/06/27/entry4.html"

  Scenario: Basic site with include tag
    Given I have a _includes directory
    And I have an "index.html" page that contains "Basic Site with include tag: {% include about.textile %}"
    And I have an "_includes/about.textile" file that contains "Generated by Jekyll"
    When I run jekyll
    Then the _site directory should exist
    And I should see "Basic Site with include tag: Generated by Jekyll" in "_site/index.html"

  Scenario: Basic site with subdir include tag
    Given I have a _includes directory
    And I have an "_includes/about.textile" file that contains "Generated by Jekyll"
    And I have an info directory
    And I have an "info/index.html" page that contains "Basic Site with subdir include tag: {% include about.textile %}"
    When I run jekyll
    Then the _site directory should exist
    And I should see "Basic Site with subdir include tag: Generated by Jekyll" in "_site/info/index.html"

  Scenario: Basic site with nested include tag
    Given I have a _includes directory
    And I have an "_includes/about.textile" file that contains "Generated by {% include jekyll.textile %}"
    And I have an "_includes/jekyll.textile" file that contains "Jekyll"
    And I have an "index.html" page that contains "Basic Site with include tag: {% include about.textile %}"
    When I debug jekyll
    Then the _site directory should exist
    And I should see "Basic Site with include tag: Generated by Jekyll" in "_site/index.html"

  Scenario: Basic site with gallery tag
    Given I have an img directory
    And I have an "img/20110310-foo-bar.jpg" file that contains " "
    And I have an "img/20110311-slug.jpg" file that contains " "
    And I have an "index.html" page that contains "{% gallery %}{{ file.title }} {{ file.date | date: "%F" }} {{ file.path }} {{ file.url }} {% endgallery %}"
    When I run jekyll
    Then the _site directory should exist
    And I should see "Slug 2011-03-11 img/20110311-slug.jpg /img/20110311-slug.jpg Foo" in "_site/index.html"
    And I should see "slug.jpg Foo Bar 2011-03-10 img/20110310-foo-bar.jpg /img/20110310-foo-bar.jpg" in "_site/index.html"

  Scenario: Basic site with gallery tag, using all options
    Given I have a downloads directory
    And I have a downloads/files directory
    And I have a "downloads/files/example-0.1.1.tar.gz" file that contains " "
    And I have a "downloads/files/example-0.2.0.tar.gz" file that contains " "
    And I have a "downloads/index.html" page that contains "{% gallery name:downloads dir:files format:tar.gz reverse:no %}{{ file.slug }} {{ file.path }} {% endgallery %}"
    When I run jekyll
    Then the _site directory should exist
    And I should see "example-0.1.1 files/example-0.1.1.tar.gz example-0.2.0 files/example-0.2.0.tar.gz" in "_site/downloads/index.html"

  Scenario: Basic site with gallery tag, where globbed files incorporate YAML Front Matter
    Given I have a documentation directory
    And I have a "documentation/introduction.textile" page with layout "chazwozzer" that contains "_Welcome!_"
    And I have an "index.html" page that contains "{% gallery dir:documentation format:textile %}{{ file.htmlpath }} {{ file.layout }}{% endgallery %}"
    When I run jekyll
    Then the _site directory should exist
    And I should see "<em>Welcome!</em>" in "_site/documentation/introduction.html"
    And I should see "documentation/introduction.html chazwozzer" in "_site/index.html"
