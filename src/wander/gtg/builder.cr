module Wander
  module GTG
    class Builder
      DUMMY = Nodes::Dummy.new

      @_followpos = {} of Nodes::Node => Array(Nodes::Node)

      def initialize(root : Nodes::Node)
        @root = root
        @ast = Nodes::Cat.new(root, DUMMY)
        # puts "A" * 50
        # puts @ast
        # puts "A" * 50
      end

      def transition_table
        dtrans = TransitionTable.new
        marked = {} of Array(Nodes::Node) => Bool
        state_id = Hash(Array(Nodes::Node::StackType), Int32).new do |h, k|
          # puts "||||| state_id"
          # puts k.inspect
          # puts h.size
          # puts "||||| state_id"
          h[k] = h.size
        end

        start = firstpos(@root)
        dstates = [start]

        # puts "dstates"
        # pp dstates
        # puts "dstates"

        until dstates.empty?
          s = (dstates.shift).as(Array(Nodes::Node))
          next if marked[s]?
          marked[s] = true

          # puts "S" * 50
          # pp s.group_by { |state| symbol(state) }
          # puts "S" * 50

          s.group_by { |state| symbol(state) }.each do |sym, ps|
            # puts "PS" * 50
            # pp ps
            # pp followpos(ps.first)
            # puts "PS" * 50

            # ps.each do |p|
            #   puts "+" * 50
            #   pp followpos(p)
            #   puts "+" * 50
            # end
            # puts "PS" * 50
            u = ps.flat_map { |l| followpos(l) }

            # puts "U" * 50
            # puts u.inspect
            # puts "U" * 50
            # next if u.empty?

            if u.uniq == [DUMMY]
              # puts "++++++++++"
              # pp state_id
              # pp u.uniq.first
              # pp state_id[u.uniq.first]
              # pp state_id
              # puts "++++++++++"

              # puts "++++++++++"
              # pp state_id[s]
              # puts "++++++++++"

              from = state_id[s]
              # puts "S #{s.inspect}"
              # puts "U #{u.uniq.inspect}"
              to = state_id[u.uniq]
              dtrans[from, to] = sym
              dtrans.add_accepting(to)
              # ps.each { |state| dtrans.add_memo(to, state.memo.not_nil!) }
            else
              dtrans[state_id[s], state_id[u]] = sym
              if u.includes?(DUMMY)
                to = state_id[u]
                accepting = ps.select { |l| followpos(l).includes?(DUMMY) }
                accepting.each { |accepting_state|
                  # dtrans.add_memo(to, accepting_state.memo.not_nil!)
                }
                dtrans.add_accepting(state_id[u])
              end
            end

            dstates << u
          end
        end

        dtrans
      end

      def nullable?(node)
        case node
        when Nodes::Group
          # puts "nullable? (NODES::GROUP)"
          true
        when Nodes::Star
          # puts "nullable? (NODES::STAR)"
          true
        when Nodes::Or
          # puts "nullable? (NODES::OR)"
          node.children.any? { |c| nullable?(c) }
        when Nodes::Cat
          # puts "nullable? (NODES::CAT)"
          nullable?(node.left) && nullable?(node.right)
        when Nodes::Terminal
          # puts "nullable? (NODES::TERMINAL) | #{node.inspect}"
          case node
          when Pegasus::Generated::Token
            !node.string
          when Nodes::Dummy
            false
          else
            !node.not_nil!.left
          end
        when Nodes::Unary
          # puts "nullable? (NODES::UNARY)"
          nullable?(node.left)
        else
          raise ArgumentError.new("unknown nullable %s" % node.class.name)
        end
      end

      def firstpos(node) : Array(Nodes::Node)
        case node
        when Nodes::Star
          # puts "firstpos (NODES:STAR)"
          firstpos(node.left)
        when Nodes::Cat
          # puts "firstpos (NODES:CAT)"
          if nullable?(node.left)
            firstpos(node.left) | firstpos(node.right)
          else
            firstpos(node.left)
          end
        when Nodes::Or
          # puts "firstpos (NODES:OR)"
          node.children.flat_map { |c| firstpos(c) }.uniq
        when Nodes::Unary
          # puts "firstpos (NODES:UNARY)"
          firstpos(node.left)
        when Nodes::Terminal
          # puts "firstpos (NODES:TERMINAL) | #{node.inspect}"
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
          # puts "lastpos (NODES:STAR)"
          firstpos(node.left)
        when Nodes::Or
          # puts "lastpos (NODES:OR)"
          node.children.flat_map { |c| lastpos(c) }.uniq
        when Nodes::Cat
          # puts "lastpos (NODES:CAT)"
          if nullable?(node.right)
            lastpos(node.left) | lastpos(node.right)
          else
            lastpos(node.right)
          end
        when Nodes::Terminal
          # puts "lastpos (NODES:TERMINAL) | #{node.inspect}"
          if nullable?(node)
            [] of Nodes::Node
          else
            [node.as(Nodes::Node)]
          end
        when Nodes::Unary
          # puts "lastpos (NODES:UNARY)"
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

        # pp @ast
        @ast.each do |n|
          # puts "|||| #{n.inspect}"

          case n
          when Nodes::Cat
            # puts "build_followpos | NODES::CAT"
            # puts "First lastpos =============="
            # pp lastpos(n.left)
            # puts "============================"

            lastpos(n.left).each do |i|
              # puts "i" * 50
              # pp i
              # puts "i" * 50
              table[i] += firstpos(n.right)
            end
          when Nodes::Star
            # puts "build_followpos | NODES::STAR"
            lastpos(n).each do |i|
              table[i] += firstpos(n)
            end
          else
            # puts "We're not supposed to be here?: #{n.inspect}"
          end
        end

        # pp table

        table
      end

      def symbol(edge)
        case edge
        when Pegasus::Generated::Token
          edge.string
        when Nodes::Symbol
          edge.regexp
        else
          edge.left
        end
      end
    end
  end
end
