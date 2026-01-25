using Graphs, SimpleWeightedGraphs, GraphRecipes,Plots
include("create_graph.jl")
include("dls.jl")
include("ids.jl")
include("uniform_cost.jl")
include("bfs.jl")
include("state_space.jl")
include("visualize.jl")

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

state_space,node_map = create_state_space()

sg, sg_labels, sg_edge_labels, sg_rev_map = prepare_graph(state_space, node_map)
write_mermaid(sg,sg_rev_map)
