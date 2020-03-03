module Wander
  module NFA
    module Dot
      def to_dot
        edges = transitions.map do |from, sym, to|
          "  #{from} -> #{to} [label=\"#{sym || 'ε'}\"]"
        end

        <<-EODOT
digraph nfa {
  rankdir=LR;
  node [shape = doublecircle];
  #{accepting_states.join(" ")};
  node [shape = circle];
  #{edges.join("\n")};
}
EODOT
      end
    end
  end
end
