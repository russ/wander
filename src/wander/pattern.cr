require "./parser"

module Wander
  class Pattern
    getter anchored : Bool

    alias RouterAST = Nodes::Node

    def self.from_string(string)
      build(
        path: string,
        requirements: {} of String => String,
        separators: "/.?",
        anchored: true)
    end

    def self.build(path : String, requirements : Hash(String, String), separators : String, anchored : Bool)
      ast = Pegasus::Generated.process(path)
      new(ast, requirements, separators, anchored)
    end

    def initialize(ast : RouterAST, requirements : Hash(String, String), separators : String, anchored : Bool)
      @spec = ast
      @requirements = requirements
      @separators = separators
      @anchored = anchored

      @names = [] of String
      @optional_names = [] of String
      @required_names = [] of String
      @re = [] of String
    end

    # def build_formatter
    #   Visitors::FormatBuilder.new.accept(spec)
    # end

    def ast
      # @spec.select(&.symbol?).each do |node|
      #   next if node.nil?
      #   puts node.inspect
      #   # re = @requirements[node.to_sym]
      #   # node.regexp = re if re
      # end

      # @spec.select(&.star?).each do |node|
      #   node = node.left
      #   node.regexp = @requirements[node.to_sym] || /(.+)/
      # end

      @spec
    end

    def names
      @names ||= spec.find_all(&:symbol?).map(&:name)
    end

    def required_names
      @required_names ||= spec.find_all(&:symbol?).map(&:name)
    end

    def optional_names
      @optional_names ||= spec.find_all(&:group?).flat_map { |group|
        group.find_all(&:symbol?)
      }.map(&:name).uniq
    end
  end
end
