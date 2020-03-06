module Wander
  module GTG
    class GTGReference; end

    class Builder
      DUMMY = Nodes::Dummy.new

      @_followpos = {} of Nodes::Node => Array(Nodes::Node)

      def initialize(root : Nodes::Node)
        @root = root
        @ast = Nodes::Cat.new(root, DUMMY)
      end

      def transition_table
        dtrans = TransitionTable.new
        marked = {} of Array(Nodes::Node) => Bool
        state_id = Hash((Array(Nodes::Node::StackType) | GTGReference), Int32).new do |h, k|
          # puts "builder:L17" + "=" * 10
          # pp k
          # puts "builder:L17" + "=" * 10 + "\n\n"
          h[k] = h.size
        end

        start = firstpos(@root)
        dstates = [start]

        until dstates.empty?
          s = (dstates.shift).as(Array(Nodes::Node))

          # puts "builder:L40:" + "=" * 10
          # s.each do |j|
          #   pp j
          # end
          # puts "builder:L44:" + "=" * 10 + "\n\n"

          next if marked[s]?
          marked[s] = true

          puts "S" * 50
          pp s
          puts "S" * 50

          s.group_by { |state| symbol(state) }.each do |sym, ps|
            u = ps.flat_map { |l| followpos(l) }

            next if u.empty?

            if u.uniq == [DUMMY]
              puts "DUMMY BRANCH"
              puts "*" * 50
              puts "S: #{state_id[s]}"
              puts "*" * 50
              puts "DUMMY BRANCH"

              from = state_id[s]
              to = state_id[GTGReference.new]
              dtrans[from, to] = sym
              dtrans.add_accepting(to)
              ps.each { |state| dtrans.add_memo(to, state.memo.not_nil!) }
            else
              # puts "S" * 50
              # pp s
              # puts "S" * 50

              # puts "U" * 50
              # pp u
              # puts "U" * 50

              s_id = state_id[s]
              u_id = state_id[u]

              puts "NOT DUMMY BRANCH"
              puts "*" * 50
              puts "S: #{s_id}"
              puts "U: #{u_id}"
              puts "*" * 50
              puts "NOT DUMMY BRANCH"

              dtrans[s_id, u_id] = sym
              if u.includes?(DUMMY)
                to = state_id[u]
                accepting = ps.select { |l| followpos(l).includes?(DUMMY) }
                accepting.each { |accepting_state|
                  dtrans.add_memo(to, accepting_state.memo.not_nil!)
                }
                dtrans.add_accepting(state_id[u])
              end
            end

            dstates << u
          end
        end

        pp state_id

        dtrans
      end

      def nullable?(node)
        case node
        when Nodes::Group
          true
        when Nodes::Star
          true
        when Nodes::Or
          node.children.any? { |c| nullable?(c) }
        when Nodes::Cat
          nullable?(node.left) && nullable?(node.right)
        when Nodes::Terminal
          if node.left.nil?
            false
          else
            !node.left.not_nil!.as(Pegasus::Generated::Token)
          end
        when Nodes::Unary
          nullable?(node.left)
        else
          raise ArgumentError.new("unknown nullable %s" % node.class.name)
        end
      end

      def firstpos(node) : Array(Nodes::Node)
        case node
        when Nodes::Star
          firstpos(node.left)
        when Nodes::Cat
          if nullable?(node.left)
            firstpos(node.left) | firstpos(node.right)
          else
            firstpos(node.left)
          end
        when Nodes::Or
          node.children.flat_map { |c| firstpos(c) }.uniq
        when Nodes::Unary
          firstpos(node.left)
        when Nodes::Terminal
          if nullable?(node)
            [] of Nodes::Node
          else
            [node.as(Nodes::Node)]
          end
        else
          raise ArgumentError.new("unknown firstpos %s" % node.class.name)
        end
      end

      def lastpos(node) : Array(Nodes::Node)
        case node
        when Nodes::Star
          firstpos(node.left)
        when Nodes::Or
          node.children.flat_map { |c| lastpos(c) }.uniq
        when Nodes::Cat
          if nullable?(node.right)
            lastpos(node.left) | lastpos(node.right)
          else
            lastpos(node.right)
          end
        when Nodes::Terminal
          if nullable?(node)
            [] of Nodes::Node
          else
            [node.as(Nodes::Node)]
          end
        when Nodes::Unary
          lastpos(node.left)
        else
          raise ArgumentError.new("unknown lastpos %s" % node.class.name)
        end
      end

      def followpos(node)
        @_followpos = build_followpos if @_followpos.empty?
        @_followpos[node]
      end

      def build_followpos
        table = Hash(Nodes::Node, Array(Nodes::Node)).new([] of Nodes::Node)

        @ast.each do |n|
          case n
          when Nodes::Cat
            lastpos(n.left).each do |i|
              table[i] += firstpos(n.right)
            end
          when Nodes::Star
            lastpos(n).each do |i|
              table[i] += firstpos(n)
            end
          end
        end

        table
      end

      def symbol(edge)
        # case edge
        # when Nodes::Symbol
        #   edge.left.not_nil!.as(Pegasus::Generated::Token).regexp
        # when Nodes::Terminal
        #   pp edge.left
        #   edge.left.not_nil!.as(Pegasus::Generated::Token).string
        # when Pegasus::Generated::Token
        #   edge.string
        # else
        #   edge.left
        # end

        case edge
        when Nodes::Dummy
          puts "E" * 50
          pp edge
          puts "E" * 50
          edge
        when Nodes::Symbol
          edge.left.not_nil!.as(Pegasus::Generated::Token).regexp
        else
          edge.left.not_nil!.as(Pegasus::Generated::Token).string
        end
      end
    end
  end
end
