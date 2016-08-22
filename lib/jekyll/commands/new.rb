require "erb"

module Jekyll
  module Commands
    class New < Command
      class << self
        def init_with_program(prog)
          prog.command(:new) do |c|
            c.syntax "new PATH"
            c.description "Creates a new Jekyll site scaffold in PATH, and " \
                        "automatically assigns site's title based on argument passed."

            c.option "force", "--force", "Force creation even if PATH already exists"
            c.option "blank", "--blank", "Creates scaffolding but with empty files"
            c.option "skip-bundle", "--skip-bundle", "Skip 'bundle install'"

            c.action do |args, options|
              Jekyll::Commands::New.process(args, options)
            end
          end
        end

        def process(args, options = {})
          raise ArgumentError, "You must specify a path." if args.empty?

          new_blog_title = extract_title args
          new_blog_path = File.expand_path(args.join(" "), Dir.pwd)

          FileUtils.mkdir_p new_blog_path

          if preserve_source_location?(new_blog_path, options)
            Jekyll.logger.abort_with "Conflict:",
                      "#{new_blog_path} exists and is not empty."
          end

          if options["blank"]
            create_blank_site new_blog_path
          else
            create_site new_blog_title, new_blog_path
          end

          after_install(new_blog_title, new_blog_path, options)
        end

        def create_blank_site(path)
          Dir.chdir(path) do
            FileUtils.mkdir(%w(_layouts _posts _drafts))
            FileUtils.touch("index.html")
          end
        end

        def scaffold_post_content
          ERB.new(File.read(File.expand_path(scaffold_path, site_template))).result
        end

        def create_config_file(title, path)
          @blog_title = title
          @user_email = user_email

          config_template = File.expand_path("_config.yml.erb", site_template)
          config_copy = ERB.new(File.read(config_template)).result(binding)

          File.open(File.expand_path("_config.yml", path), "w") do |f|
            f.write(config_copy)
          end
        end

        # Internal: Gets the filename of the sample post to be created
        #
        # Returns the filename of the sample post, as a String
        def initialized_post_name
          "_posts/#{Time.now.strftime("%Y-%m-%d")}-welcome-to-jekyll.markdown"
        end

        private

        def extract_title(args)
          a = args.join(" ")
          a.tr("\\", "/").split("/").last
        end

        def gemfile_contents
          <<-RUBY
source "https://rubygems.org"
ruby RUBY_VERSION

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
gem "jekyll", "#{Jekyll::VERSION}"

# This is the default theme for new Jekyll sites. You may change this to anything you like.
gem "minima"

# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
# gem "github-pages", group: :jekyll_plugins

# If you have any plugins, put them here!
group :jekyll_plugins do
   gem "jekyll-feed", "~> 0.6"
end
RUBY
        end

        def create_site(new_blog_title, new_blog_path)
          create_sample_files new_blog_title, new_blog_path

          File.open(File.expand_path(initialized_post_name, new_blog_path), "w") do |f|
            f.write(scaffold_post_content)
          end

          File.open(File.expand_path("Gemfile", new_blog_path), "w") do |f|
            f.write(gemfile_contents)
          end
        end

        def preserve_source_location?(path, options)
          !options["force"] && !Dir["#{path}/**/*"].empty?
        end

        def erb_files(title)
          erb_file = File.join("**", title.to_s, "**", "*.erb")
          Dir.glob(erb_file)
        end

        def create_sample_files(title, path)
          FileUtils.cp_r site_template + "/.", path
          create_config_file title, path
          erb_files(title).each do |file|
            FileUtils.rm file
          end
        end

        def site_template
          File.expand_path("../../site_template", File.dirname(__FILE__))
        end

        def scaffold_path
          "_posts/0000-00-00-welcome-to-jekyll.markdown.erb"
        end

        # After a new blog has been created, print a success notification and
        # then automatically execute bundle install from within the new blog dir
        # unless the user opts to generate a blank blog or skip 'bundle install'.

        def after_install(title, path, options = {})
          Jekyll.logger.info "New jekyll site #{title.cyan} installed in #{path.cyan}."
          Jekyll.logger.info "Bundle install skipped." if options["skip-bundle"]

          unless options["blank"] || options["skip-bundle"]
            bundle_install path
          end
        end

        def bundle_install(path)
          Jekyll::External.require_with_graceful_fail "bundler"
          Jekyll.logger.info "Running bundle install in #{path.cyan}..."
          Dir.chdir(path) do
            system("bundle", "install")
          end
        end

        def user_email
          gitconfig_email = `git config user.email`.chomp
          gitconfig_email.empty? ? "your-email@domain.com" : gitconfig_email
        end
      end
    end
  end
end
