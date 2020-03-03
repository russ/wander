require "string_scanner"

module Wander
  class Scanner
    def initialize(string)
      @ss = StringScanner.new(string)
    end

    def eos?
      @ss.eos?
    end

    def pos
      @ss.offset
    end

    def next_token
      return if @ss.eos?
      until token = scan || @ss.eos?; end
      token
    end

    private def scan
      case
      when text = @ss.scan(/\//)
        [:SLASH, text]
      when text = @ss.scan(/\*\w+/)
        [:STAR, text]
      when text = @ss.scan(/\(/)
        [:LPAREN, text]
      when text = @ss.scan(/\)/)
        [:RPAREN, text]
      when text = @ss.scan(/\|/)
        [:OR, text]
      when text = @ss.scan(/\./)
        [:DOT, text]
      when text = @ss.scan(/:\w+/)
        [:SYMBOL, text]
      when text = @ss.scan(/[\w%\-~]+/)
        [:LITERAL, text]
      when text = @ss.scan(/./)
        [:LITERAL, text]
      end
    end
  end
end
