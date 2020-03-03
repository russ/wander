module Wander
  module Nodes
    DEFAULT_EXP = /[^\.\/\?]+/

    class Symbol < Node
      def initialize(@left)
        super
        # @regexp = DEFAULT_EXP
      end

      def node_type
        "SYMBOL"
      end

      def default_regexp?
        regexp == DEFAULT_EXP
      end
    end
  end
end
