require "./spec_helper"

include Wander

describe Wander do
  # it "runs through /" do
  #   table = tt(%w(/))
  #   result = GTG::Simulator.new(table).memos("/")
  #   result.size.should eq(1)
  # end

  it "can handle more than one path" do
    table = tt(%w(/foo /bar))
    # pp table
    pp table.string_states
    result = GTG::Simulator.new(table).memos("/foo")
    result.size.should eq(1)
  end
end
