require "string_scanner"

module Wander
  module GTG
    class MatchData
      def intialize(memos)
        @memos = memos
      end
    end

    class Simulator
      def initialize(transition_table : TransitionTable)
        @tt = transition_table
        # puts "=" * 50
        # puts "TRANSITION TABLE"
        # puts @tt.inspect
        # puts "=" * 50
      end

      def memos(string)
        input = StringScanner.new(string)
        state = [0]
        while sym = input.scan(%r([/.?]|[^/.?]+))
          # puts "=" * 50
          # puts "State: #{state}"
          # puts "Sym: #{sym}"
          # puts "=" * 50
          state = @tt.mov(state, sym)
        end

        acceptance_states = state.select { |s|
          @tt.accepting?(s)
        }

        # return yield if acceptance_states.empty?

        acceptance_states.flat_map { |x| @tt.memo(x) }.compact
      end
    end
  end
end
