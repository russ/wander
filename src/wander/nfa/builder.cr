module Wander
  module NFA
    class Visitor < Visitors::Visitor
      def initialize(@tt : NFA::TransitionTable)
        @i = -1
      end

      def visit_cat(node)
        left = visit(node.left)
        right = visit(node.right)

        @tt.merge(left.last, right.first)

        [left.first, right.last]
      end

      def visit_group(node)
        from = @i += 1
        left = visit(node.left)
        to = @i += 1

        @tt.accepting = to

        @tt[from, left.first] = nil
        @tt[left.last, to] = nil
        @tt[from, to] = nil

        [from, to]
      end

      def visit_or(node)
        from = @i += 1
        children = node.children.map { |c| visit(c) }
        to = @i += 1

        children.each do |child|
          @tt[from, child.first] = nil
          @tt[child.last, to] = nil
        end

        @tt.accepting = to

        [from, to]
      end

      def terminal(node)
        from_i = @i += 1 # new state
        to_i = @i += 1   # new state

        @tt[from_i, to_i] = node
        @tt.accepting = to_i
        @tt.add_memo(to_i, node.memo)

        [from_i, to_i]
      end
    end

    class Builder
      def initialize(@ast : Nodes::Node | Pegasus::Generated::Token | String)
      end

      def transition_table
        tt = TransitionTable.new
        Visitor.new(tt).accept(@ast)
      end
    end
  end
end
