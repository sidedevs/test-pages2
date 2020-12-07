# frozen_string_literal: true

module Jekyll
  module Taxonomy
    class Page < PageWithoutAFile
      attr_reader :site, :type, :name, :linked_docs, :relative_path
      alias_method :basename_without_ext, :name

      def initialize(site, type, name, linked_docs)
        @site = site
        @name = name
        @type = type.to_sym
        @ext  = ".html"
        @content = ""
        @linked_docs = linked_docs
        @relative_path = "#{type}_page_#{name}.html"
      end

      def data
        @data ||= site.frontmatter_defaults.all(relative_path, type)
      end

      def url
        @url ||= URL.new(
          :placeholders => url_placeholders,
          :permalink    => permalink
        ).to_s
      end

      def url_placeholders
        {
          :path       => relative_path,
          :basename   => basename_without_ext,
          :output_ext => output_ext,
        }
      end

      def to_liquid
        @to_liquid ||= Taxonomy::PageDrop.new(self)
      end

      def inspect
        "#<#{self.class.name} #{relative_path}>"
      end
    end
  end
end
