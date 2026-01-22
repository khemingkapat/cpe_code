using Graphs, SimpleWeightedGraphs, GraphRecipes,Plots
include("create_graph.jl")
include("dls.jl")
include("ids.jl")

graph, mapping = create_graph()

result = ids(graph, mapping, "A", "B")
println(result)
