using DataStructures,Graphs,SimpleWeightedGraphs
include("create_map.jl")
include("best_first.jl")
include("a_star.jl")
include("hill_climbing.jl")
include("create_graph.jl")
include("bfs.jl")
include("dls.jl")
include("uniform_cost.jl")
include("ids.jl")

graph, mapping, h_values = create_graph()

result, path = bfs(graph, mapping, "S", ["G1","G2","G3"])
println("bfs","|",result,"|",path)
println()

result, path = dls(graph, mapping, "S", ["G1","G2","G3"])
println("dfs","|",result,"|",path)
println()

result, path = uniform_cost(graph, mapping, "S", ["G1","G2","G3"])
println("uniform_cost","|",result,"|",path)
println()

result, path = ids(graph, mapping, "S", ["G1","G2","G3"])
println("ids","|",result,"|",path)
println()

result, path = greedy_best_first_search_graph(graph, mapping, h_values, "S", ["G1","G2","G3"])
println("gbfs","|",result,"|",path)
println()

result, path = a_star_graph(graph, mapping, h_values, "S", ["G1","G2","G3"])
println("a star","|",result,"|",path)
println()

result, path = ida_star_graph(graph, mapping, h_values, "S", ["G1","G2","G3"])
println("ida star","|",result,"|",path)
println()
