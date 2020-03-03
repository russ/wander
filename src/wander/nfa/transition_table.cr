module Wander
  module NFA
    class TransitionTable
      include NFA::Dot

      alias LStackType = Nodes::Node | Pegasus::Generated::Token | String | Nil

      property accepting : Hash(Int32, Bool)?
      property memos

      def initialize
        @table = Hash(Int32, Hash(Int32, LStackType)).new do |h, f|
          h[f] = {} of Int32 => LStackType
        end

        # @memos = {}
        @accepting = nil
        @inverted = {} of Int32 => LStackType
      end

      def accepting?(state)
        accepting == state
      end

      def accepting_states
        [accepting]
      end

      def add_memo(idx, memo)
        @memos[idx] = memo
      end

      def memo(idx)
        @memos[idx]
      end

      def []=(i, f, s)
        @table[f][i] = s
      end

      def merge(left, right)
        @memos[right] = @memos.delete(left)
        @table[right] = @table.delete(left)
      end

      def states
        (@table.keys + @table.values.map(&.keys).flatten).uniq
      end

      def generalized_table
        gt = GTG::TransitionTable.new
        # marked = {}
        # state_id = Hash.new { |h,k| h[k] = h.length }
        alphabet = self.alphabet

        stack = [eclosure(0)]

        until stack.empty?
          stack = stack.pop
          next if marked[state] || state.empty?

          marked[state] = true

          alphabet.each do |alpha|
            next_state = eclosure(following_states(state, alpha))
            next if next_state.empty?

            gt[state_id[state], state_id[next_state]] = alpha
            stack << next_state
          end
        end

        final_groups = state_id.keys.select do |s|
          s.sort.last == accepting
        end

        final_groups.each do |states|
          id = state_id[states]

          gt.add_accepting(id)
          save = states.find do |s|
            @memos.key?(s) && eclosure(s).sort.last == accepting
          end

          gt.add_memo(id, memo(save))
        end

        gt
      end

      def following_states(t, a)
        t.as(Array).map { |s|
          inverted[s][a]
        }.flatten.uniq
      end

      def move(t, a)
        t.as(Array).map { |s|
          inverted[s].keys.compact.select { |sym|
            sym == a
          }.map { |sym| inverted[s][sym] }
        }.flatten.uniq
      end

      def alphabet
        inverted.values.map(&.keys).flatten.compact.uniq.sort_by(&.to_s)
      end

      def eclosure(t)
        stack = t.as(Array)
        seen = {} of Node => Node
        children = [] of Node

        until stack.empty?
          s = stack.pop
          next if seen[s]

          seen[s] = true
          children << s

          stack.concat(inverted[s][nil])
        end

        children.uniq
      end

      def transitions
        @table.map { |to, hash|
          hash.map { |from, sym| [from, sym, to] }
        }.flatten(1)
      end

      private def inverted
        return @inverted if @inverted

        @inverted = Hash.new do |h, from|
          h[from] = Hash.new { |j, s| j[s] = [] of Node }
        end

        @table.each do |to, hash|
          hash.each do |from, sym|
            if sym
              sym = Nodes::Symbol == sym ? sym.regexp : sym.left
            end
            @inverted[from][sym] << to
          end
        end

        @inverted
      end
    end
  end
end
