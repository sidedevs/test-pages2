# frozen_string_literal: true

module Jekyll
  module SiteData
    class File
      attr_accessor :context

      def initialize(site, path, content)
        @site = site
        @path = path
        @content = content
      end

      def to_liquid
        add_regenerator_dependencies if incremental_build?
        @content
      end

      # Overrides to maintain backwards compatibility.

      # Any missing method will be forwarded to the underlying data object stored in
      #   the instance variable `@content`.
      def method_missing(method, *args, &block)
        @content.send(method, *args, &block) || super
      end

      def respond_to_missing?(method, *)
        @content.respond_to?(method) || super
      end

      private

      def incremental_build?
        @incremental = @site.incremental? if @incremental.nil?
        @incremental
      end

      def add_regenerator_dependencies
        page = context.registers[:page]
        return unless page&.key?("path")

        page_path = context.registers[:page]["path"]
        absolute_path = \
          if page["collection"]
            @site.in_source_dir(@site.config["collections_dir"], page_path)
          else
            @site.in_source_dir(page_path)
          end

        @site.regenerator.add_dependency(absolute_path, @path)
      end
    end
  end
end
