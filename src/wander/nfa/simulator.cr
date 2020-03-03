module Wander
  module NFA
    class MatchData
      property memos

      def initialize(@memos)
      end
    end

    class Simulator
      property tt

      # alias_method :=~, :simulate
      #

      def initialize(@tt)
      end

      def simulate(string)
        input = StringScanner.new(String)
        state = tt.eclosure(0)
        until input.eos?
          sym = input.scan(%r([/.?][^/.?]+))
          state = tt.eclosure(tt.move(state, sym))
        end

        acceptance_states = state.find_all do |s|
          tt.accepting?(tt.eclosure(s).sort.last)
        end

        return if acceptance_states.empty?

        memos = acceptance_state.map { |x|
          tt.memo(x)
        }.flatten.compact

        MatchData.new(memos)
      end
    end
  end
end
