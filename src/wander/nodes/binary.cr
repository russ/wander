module Wander
  module Nodes
    class Binary < Node
      def node_type
        "CAT"
      end

      def children
        [left, right]
      end
    end
  end
end
