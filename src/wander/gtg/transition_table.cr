require "../nfa/dot"

module Wander
  module GTG
    class TransitionTable
      include NFA::Dot

      alias StackType = Nodes::Node::StackType

      getter memos : Hash(Int32, Array(StackType))
      # TODO: Remove this when it's not needed for debugging
      getter string_states : Hash(Int32, Hash(String, Int32))
      getter regexp_states : Hash(String, Hash(String, Int32))

      def initialize
        @regexp_states = {} of String => Hash(String, Int32)
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

      def move(t, a)
        return [] of String if t.empty?

        regexps = [] of Int32
        strings = [] of Int32

        t.each do |s|
          # puts "-" * 50
          # puts "S: #{s}"
          # puts "-" * 50

          if states = @regexp_states[s]?
            states.each do |re, v|
              if Regex.new(re).match(a) && !v.nil?
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
        puts "-" * 50
        puts "From: #{from.inspect}"
        puts "To: #{to.inspect}"
        puts "Sym: #{sym.inspect}"
        # if sym.is_a?(Pegasus::Generated::Token)
        #   puts "Sym: #{sym.as(Pegasus::Generated::Token).string.inspect}"
        # else
        #   puts "Sym: #{sym.inspect}"
        # end
        puts "-" * 50

        case sym
        # when Pegasus::Generated::Token
        #   @string_states[from][sym.string] = to
        when String
          @string_states[from][sym] = to
        when Regex
          unless @regexp_states[from.to_s]?
            @regexp_states[from.to_s] = {} of String => Int32
          end
          @regexp_states[from.to_s][sym.to_s] = to
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

      # private def states_hash_for(sym)
      #   case sym
      #   when String
      #     @string_states
      #   when Regex
      #     @regexp_states
      #   else
      #     raise "unknown symbol: %s" % sym.class
      #   end
      # end
    end
  end
end
