module Wander
  module Nodes
    class Or < Node
      alias ChildrenType = Array(Nodes::Node)

      getter children : ChildrenType

      def initialize(children : ChildrenType)
        @left, @right = Dummy.new, Dummy.new
        @children = children.as(ChildrenType)
      end

      def node_type
        "OR"
      end
    end
  end
end
