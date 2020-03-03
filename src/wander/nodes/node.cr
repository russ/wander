require "../visitors/visitor"

module Wander
  module Nodes
    abstract class Node
      include Enumerable(Node)

      alias StackType = Nodes::Node

      property left : StackType?
      property right : StackType?
      property regexp : Regex?
      property memo : StackType?

      def initialize
        @left, @right = nil, nil
      end

      def initialize(@left)
        @right = nil
      end

      def initialize(@left, @right)
      end

      def each(&block : Node -> _)
        Visitors::Each::INSTANCE.accept(self, block)
      end

      def children
        [] of StackType
      end

      abstract def node_type
    end
  end
end

require "./terminal"
require "./literal"
require "./binary"
require "./cat"
require "./dot"
require "./dummy"
require "./group"
require "./node"
require "./or"
require "./slash"
require "./star"
require "./symbol"
require "./token"
require "./unary"
