module Wander
  module Visitors
    class Each < FunctionalVisitor
      INSTANCE = new

      def visit(node, &block)
        block.call(node)
        super
      end
    end
  end
end
