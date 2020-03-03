require "../nfa/dot"

module Wander
  module GTG
    class TransitionTable
      include NFA::Dot

      alias StackType = Nodes::Node::StackType

      getter memos : Hash(Int32, Array(StackType))
      # TODO: Remove this when it's not needed for debugging
      getter string_states : Hash(Int32, Hash(String, Int32))

      def initialize
        @regexp_states = {} of String => Hash(Regex, Int32)
        @string_states = Hash(Int32, Hash(String, Int32)).new do |h, k|
          h[k] = {} of String => Int32
        end
        @accepting = {} of Int32 => Bool
        @memos = Hash(Int32, Array(StackType)).new(->(hash : Hash(Int32, Array(StackType)), key : Int32) {
          hash[key] = [] of StackType
        })
      end

      def add_accepting(state : Int32)
        # puts "adding accepting : #{state}"
        @accepting[state] = true
      end

      def accepting_states
        @accepting.keys
      end

      def accepting?(state)
        @accepting[state]?
      end

      def add_memo(idx : Int32, memo : StackType)
        # puts "adding memo"
        @memos[idx] << memo
      end

      def memo(idx)
        @memos[idx]
      end

      def to_svg
        svg = Process.run("dot", ["-Tsvg", "w+"], input: IO::Memory.new(to_dot)) do |f|
          # f.write(to_dot)
          # f.close_write
          # f.readlines
          f.output.gets_to_end.split("\n")
        end
        3.times { svg.shift }
        svg.join.sub(/width="[^"]*"/, "").sub(/height="[^"]*"/, "")
      end

      def visualizer(paths, title = "FSM")
        fun_routes = paths.shuffle.first(3).map do |ast|
          ast.map { |n|
            case n
            when Nodes::Symbol
              case n.left
              when ":id"     then rand(100).to_s
              when ":format" then %w{xml json}.shuffle.first
              else
                "omg"
              end
            when Nodes::Terminal
              n.symbol
            else
              nil
            end
          }.compact.join
        end
      end

      def mov(t, a)
        return [] of String if t.empty?

        regexps = [] of Int32
        strings = [] of Int32

        t.each do |s|
          # puts "-" * 50
          # puts "S: #{s}"
          # puts "-" * 50

          if states = @regexp_states[s]?
            states.each do |re, v|
              if re.match(a) && !v.nil?
                regexps << v
              end
            end
          end

          if states = @string_states[s]?
            # puts "=" * 50
            # puts a.inspect
            # puts states[a].inspect
            # puts states.inspect
            # puts "=" * 50
            strings << states[a] unless states[a]?.nil?
          end
        end

        # puts "-" * 50
        # puts "Strings: #{strings}"
        # puts "Regexps: #{regexps}"
        # puts "-" * 50

        strings + regexps
      end

      def []=(from, to, sym)
        # puts "-" * 50
        # puts "From: #{from.inspect}"
        # puts "To: #{to.inspect}"
        # puts "Sym: #{sym.inspect}"
        # puts "-" * 50
        case sym
        when Pegasus::Generated::Token
          @string_states[from][sym.string] = to
        when String
          @string_states[from][sym] = to
          # TODO: Make this work again
          # when Regex
          #   puts "-" * 50
          #   puts "From: #{from.inspect}"
          #   puts "To: #{to.inspect}"
          #   puts "Sym: #{sym.inspect}"
          #   puts "-" * 50
          #   @regexp_states[from][sym] = to
          # TODO: Shouldn't have this?
        when Nil
          puts "..."
        else
          raise "unknown symbol: %s" % sym.class
        end
      end

      def states
        ss = @string_states.keys + @string_states.values.flat_map(&.values)
        rs = @regexp_states.keys + @regexp_states.values.flat_map(&.values)
        (ss + rs).uniq
      end

      def transitions
        @string_states.flat_map { |from, hash|
          hash.map { |s, to| [from, s, to] }
        } + @regexp_states.flat_map { |from, hash|
          hash.map { |s, to| [from, s, to] }
        }
      end
    end
  end
end
