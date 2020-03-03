module Wander
  module Router
    class Route
      getter path : Pattern

      def initialize(@path : Pattern)
      end

      def ast
        # @_decorated_ast ||= begin
        decorated_ast = path.ast
        decorated_ast.select(&.terminal?).each do |n|
          n.memo = self
        end
        decorated_ast
        # end
      end

      def segments
        path.names
      end

      def required_keys
        required_parts + required_defaults.keys
      end

      def score(supplied_keys)
        path.required_anmes.each do |k|
          return -1 unless supplied_keys.include?(k)
        end

        score = 0
        path.names.each do |k|
          score += 1 if supplied_keys.include?(k)
        end

        score + (required_defaults.length * 2)
      end

      def parts
        @parts ||= segments.map(&:to_sym)
      end

      def required_parts
        @required_parts ||= path.required_names.map(&:to_sym)
      end

      def required_default?(key)
        @_required_defaults.include?(key)
      end

      def required_defaults
        @required_defaults ||= @defaults.dup.delete_if do |k, _|
          parts.include?(k) || !required_default?(k)
        end
      end

      def glob?
        path.spec.any?(Nodes::Star)
      end
    end
  end
end
