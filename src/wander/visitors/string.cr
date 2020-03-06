module Wander
  module Visitors
    class String < FunctionalVisitor
      INSTANCE = new

      private def nary(node, seed)
        last_child = node.not_nil!.children.last
        node.not_nil!.children.reduce(seed) { |s, c|
          string = visit(c, s)
          string << "|" unless last_child == c
          string
        }
      end

      private def terminal(node, seed)
        if node.is_a?(Nodes::Dummy)
          seed
        else
          seed << node.not_nil!.left.not_nil!.as(Pegasus::Generated::Token).string
        end
      end

      private def visit_group(node, seed)
        visit(node.not_nil!.left, seed.dup << "(") << ")"
      end
    end
  end
end
