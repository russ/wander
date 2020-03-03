require "spec"
require "../src/wander"
require "../src/wander/gtg/*"

def asts(paths)
  paths.map do |x|
    ast = Pegasus::Generated.process(x)
    ast.each do |n|
      n.not_nil!.memo = ast unless n.nil?
    end
    ast
  end
end

def tt(paths)
  x = asts(paths)
  builder = GTG::Builder.new(Nodes::Or.new(x))
  builder.transition_table
end

def simulator_for(paths)
  GTG::Simulator.new(tt(paths))
end
