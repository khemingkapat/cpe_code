using Graphs, SimpleWeightedGraphs, GraphRecipes,Plots
include("create_graph.jl")
include("dls.jl")
include("ids.jl")
include("uniform_cost.jl")
include("bfs.jl")

graph, mapping = create_graph()

result,path = bfs(graph, mapping, "A", "B")
println("bfs","|",result,"|",path)
println()

result,path = uniform_cost(graph, mapping, "A", "B")
println("uniform_cost","|",result,"|",path)
println()

result,path = dls(graph, mapping, "A", "B")
println("dfs","|",result,"|",path)
println()

result,path = dls(graph, mapping, "A", "B",3)
println("dls(3)","|",result,"|",path)
println()

result,path = ids(graph, mapping, "A", "B")
println("ids","|",result,"|",path)
println()
