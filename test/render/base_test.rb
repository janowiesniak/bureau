require "test_helper"

module Bureau
  module Render
    class BaseTest < TestCase

      it "return header" do
        assert_equal [1,2], Bureau::Render::Base.new([1,2],[3,4]).header
      end

      it "return rows" do
        assert_equal [3,4], Bureau::Render::Base.new([1,2],[3,4]).rows
      end

      it "return a package" do
        assert_kind_of Axlsx::Package, renderer.package
      end

      it "return a workbook" do
        assert_kind_of Axlsx::Workbook, renderer.workbook
      end

      it "return a worksheet" do
        assert_kind_of Axlsx::Worksheet, renderer.worksheet
      end

      it "render - apply collection" do
        assert_equal [], renderer.collection.applied
        renderer.render

        assert_equal renderer.features, renderer.collection.applied
      end

      it "apply specific collection" do
        renderer = renderer_class.new(header, rows, :features => [Bureau::Features::Filter])
        renderer.render

        assert_equal [Bureau::Features::Filter], renderer.collection.applied
      end

      it "feature filter" do
        assert_nil renderer.worksheet.auto_filter.range

        renderer.collection.add(Bureau::Features::Filter)
        renderer.collection.apply!

        assert_equal "A1:B2", renderer.worksheet.auto_filter.range
      end

      it "feature docked" do
        assert_nil renderer.worksheet.sheet_view.pane.top_left_cell
        assert_nil renderer.worksheet.sheet_view.pane.state
        assert_equal 0, renderer.worksheet.sheet_view.pane.y_split
        assert_equal 0, renderer.worksheet.sheet_view.pane.x_split

        renderer.collection.add(Bureau::Features::Docked)
        renderer.collection.apply!

        assert_equal 'B2', renderer.worksheet.sheet_view.pane.top_left_cell
        assert_equal 'frozenSplit', renderer.worksheet.sheet_view.pane.state
        assert_equal 1, renderer.worksheet.sheet_view.pane.y_split
        assert_equal 0, renderer.worksheet.sheet_view.pane.x_split
      end

      it "set default sheet name" do
        assert_equal "Sheet", renderer.worksheet.name
      end

      it "set optional sheet name" do
        renderer = renderer_class.new(header, rows, :name => "MySheet")

        assert_equal "MySheet", renderer.worksheet.name
      end

      # TODO: Integrationtest - Open xlsx again
      it "render - return xlsx" do
        assert renderer.render
      end

      private

      def renderer_class
        Bureau::Render::Base
      end

      def renderer
        @instance ||= renderer_class.new(header, rows)
      end

      def header
        @header ||= [cell("foo"), cell(1)]
      end

      def rows
        @rows ||= [header]
      end

      def cell(item)
        Class.new { include Bureau::Cell::Base }.new(item)
      end

    end
  end
end
