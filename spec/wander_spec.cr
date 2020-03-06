require "./spec_helper"

include Wander

describe Wander do
  # it "runs through /" do
  #   table = tt(%w(/))
  #   result = GTG::Simulator.new(table).memos("/")
  #   result.size.should eq(1)
  # end

  it "can handle more than one path" do
    table = tt(%w(/my/favorites/:username/month))

    pp table.string_states
    # pp table.states
    # pp table.transitions
    # pp table.accepting_states
    # pp table.string_states

    result = GTG::Simulator.new(table).memos("/foo")
    result.size.should eq(1)

    # tt(%w(/strack/:code/:site/:program(/:track(/*path))))
  end

  # it "" do
  #   node = Nodes::Cat.new(Nodes::Slash.new(Pegasus::Generated::Token.new(1.to_i64, "/")), Nodes::Dummy.new)

  #   puts "=" * 50
  #   pp node.build_string.to_s
  #   puts "=" * 50
  # end
end
