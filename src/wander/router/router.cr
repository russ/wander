module Wander
  module Router
    class Router
      property routes : Routes

      def initialize(@routes : Routes)
      end

      def recognize(request : Request)
        find_routes(request).each do |route|
          yield(routes)
        end
      end

      def visualizer
        tt = GTG::Builder.new(ast).transition_table
        groups = partitioned_routes.first.map(&.ast).group_by(&.to_s)
        asts = group.values.map(&.first)
        tt.visualizer(asts)
      end

      private def partitioned_routes
        routes.partitioned_routes
      end

      private def ast
        routes.ast
      end

      private def simulator
        routes.simulator
      end

      private def find_routes(request : Request)
        filter_routes(request.path_info)
      end

      private def filter_routes(path)
        return [] of Route unless routes.ast
        simulator.memos(path) { [] of String }
      end
    end
  end
end
