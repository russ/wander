module Wander
  module Visitors
    class String < FunctionalVisitor
      INSTANCE = new

      private def binary(node, seed)
        visit(node.right, visit(node.left, seed))
      end

      private def nary(node, seed)
        last_child = node.children.last
        node.children.inject(seed) { |s, c|
          string = visit(c, s)
          string << "|" unless last_child == c
          string
        }
      end

      private def terminal(node, seed)
        seed + node.left
      end

      private def visit_group(node, seed)
        visit(node.left, seed.dup << "(") << ")"
      end
    end
  end
end
