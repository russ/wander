require "./gtg/simulator"

module Wander
  module Router
    class Routes
      include Enumerable(Route)

      getter routes : Array(Route)
      getter anchored_routes : Array(Route)
      getter custom_routes : Array(Route)

      def initialize(@routes : Array(Route))
        @anchored_routes = [] of Route
        @custom_routes = [] of Route
      end

      def empty?
        routes.empty?
      end

      def length
        routes.length
      end

      def last
        routes.last
      end

      def each
        routes.each do |route|
          yield route
        end
      end

      def clear
        @routes.clear
        @anchored_routes.clear
        @custom_routes.clear
      end

      def partition_route(route)
        if route.path.anchored && route.ast.select(&.symbol?).all?(&.default_regexp?)
          anchored_routes << route
        else
          custom_routes << route
        end
      end

      def ast
        # @ast ||= begin
        asts = anchored_routes.map(&.ast)
        Nodes::Or.new(asts)
        # end
      end

      def simulator
        # @simulator ||= begin
        gtg = ::GTG::Builder.new(ast).transition_table
        GTG::Simulator.new(gtg)
        # end
      end

      def add_route(name, path)
        route = Route.new(path: Pattern.from_string(path))
        routes << route
        partition_route(route)
        pp routes
        clear_cache!
        route
      end

      private def clear_cache!
        # @ast = nil
        # @simulator = nil
      end
    end
  end
end
