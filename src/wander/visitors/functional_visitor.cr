module Wander
  module Visitors
    class FunctionalVisitor
      def accept(node, seed)
        visit(node, seed)
      end

      def visit(node, seed : ::String::Builder)
        # puts "Visiting: #{node.inspect}"

        case node.not_nil!.node_type
        when "CAT"     then visit_cat(node, seed)
        when "OR"      then visit_or(node, seed)
        when "GROUP"   then visit_group(node, seed)
        when "LITERAL" then visit_literal(node, seed)
        when "SYMBOL"  then visit_symbol(node, seed)
        when "SLASH"   then visit_slash(node, seed)
        when "DOT"     then visit_dot(node, seed)
        when "BINARY"  then binary(node, seed)
        when "STAR"    then unary(node, seed)
        else
          if node.is_a?(Pegasus::Generated::Token)
            terminal(node, seed)
          else
            raise ArgumentError.new("Unknown node type when visiting: #{node.inspect}")
          end
        end
      end

      def visit(node, seed)
        # puts "Visiting: #{node.inspect}"
        seed.call(node.not_nil!) unless node.nil? || seed.nil?

        case node.not_nil!.node_type
        when "CAT"     then visit_cat(node, seed)
        when "OR"      then visit_or(node, seed)
        when "GROUP"   then visit_group(node, seed)
        when "LITERAL" then visit_literal(node, seed)
        when "SYMBOL"  then visit_symbol(node, seed)
        when "SLASH"   then visit_slash(node, seed)
        when "DOT"     then visit_dot(node, seed)
        when "BINARY"  then binary(node, seed)
        when "STAR"    then unary(node, seed)
        else
          # if node.is_a?(Pegasus::Generated::Token)
          #   terminal(node, seed)
          # else
          raise ArgumentError.new("Unknown node type when visiting: #{node.inspect}")
          # end
        end
      end

      private def nary(node, seed)
        node.not_nil!.children.reduce(seed) do |s, c|
          visit(c, s)
        end
      end

      private def unary(node, seed)
        visit(node.not_nil!.left, seed)
      end

      private def binary(node, seed)
        visit(node.not_nil!.right, visit(node.not_nil!.left, seed))
      end

      private def visit_or(n, seed)
        nary(n, seed)
      end

      private def visit_cat(n, seed)
        binary(n, seed)
      end

      private def visit_group(n, seed)
        unary(n, seed)
      end

      private def visit_star(n, seed)
        unary(n, seed)
      end

      private def visit_literal(node, seed)
        terminal(node.not_nil!.left, seed)
      end

      private def visit_symbol(node, seed)
        terminal(node.not_nil!.left, seed)
      end

      private def visit_slash(node, seed)
        terminal(node.not_nil!.left, seed)
      end

      private def visit_dot(node, seed)
        terminal(node.not_nil!.left, seed)
      end

      private def terminal(node, seed)
        seed
      end
    end
  end
end
