module Wander
  module Nodes
    class Unary < Node
      def node_type
        "UNARY"
      end

      def children
        [left]
      end
    end
  end
end
