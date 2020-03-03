# wander

TODO: Write a description here

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     wander:
       github: russ/wander
   ```

2. Run `shards install`

## Usage

```crystal
require "wander"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/russ/wander/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Russ Smith](https://github.com/russ) - creator and maintainer



``` crystal
class Visitor
  def accept(node, seed)
    visit(node, seed)
  end
 
  def visit(node, seed)
    seed.call(node.not_nil!) unless node.nil?
    if node.not_nil!.left
      visit(node.not_nil!.left, seed)
    end
  end
end
 
class Each < Visitor
  def visit(node, &block)
    block.call(node)
    super
  end
 
  INSTANCE = new
end
 
class Node
  property name : String
  property left : Node?
 
  def initialize(@name)
    @left = nil
  end
 
  def initialize(@name, @left)
  end
 
  def each(&block : Node -> _)
    Each::INSTANCE.accept(self, block)
  end
end
 
Node.new("outer", Node.new("inner")).each do |node|
  puts node.name
end
```

#<Journey::GTG::TransitionTable:0x00005597ddc4a458
 @accepting={2=>true, 3=>true},
 @memos=
  {2=>
    [#<Journey::Nodes::Cat:0x00005597ddc34310
      @left=
       #<Journey::Nodes::Slash:0x00005597ddc345e0
        @left="/",
        @memo=#<Journey::Nodes::Cat:0x00005597ddc34310 ...>>,
      @memo=#<Journey::Nodes::Cat:0x00005597ddc34310 ...>,
      @right=
       #<Journey::Nodes::Literal:0x00005597ddc34388
        @left="foo",
        @memo=#<Journey::Nodes::Cat:0x00005597ddc34310 ...>>>],
   3=>
    [#<Journey::Nodes::Cat:0x00005597ddc4b7b8
      @left=
       #<Journey::Nodes::Slash:0x00005597ddc4b920
        @left="/",
        @memo=#<Journey::Nodes::Cat:0x00005597ddc4b7b8 ...>>,
      @memo=#<Journey::Nodes::Cat:0x00005597ddc4b7b8 ...>,
      @right=
       #<Journey::Nodes::Literal:0x00005597ddc4b808
        @left="bar",
        @memo=#<Journey::Nodes::Cat:0x00005597ddc4b7b8 ...>>>]},
 @regexp_states={},
 @string_states={0=>{"/"=>1}, 1=>{"foo"=>2, "bar"=>3}}>
