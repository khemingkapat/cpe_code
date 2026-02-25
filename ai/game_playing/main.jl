using Plots, GraphRecipes

include("nim.jl")
include("minimax.jl")
include("visualize.jl")
include("alpha_beta.jl")
include("custom.jl")
g, node_map, id_to_state = create_nim(6)
node_values = assign_leaf_nodes(g,id_to_state)
node_values, new_id_to_state = minimax(g, node_map, id_to_state,node_values)
write_mermaid(g,new_id_to_state)
println()
root = find_root_node(g)
levels = map_node_levels(g, root)
final_score = alpha_beta_recursive(g, node_values, root, -Inf, Inf, levels,id_to_state,print_name=false)
println()
println("final score of root is $final_score")
#
#
# g,node_map,id_to_state = create_custom_graph()
# node_values = assign_custom_leaf_nodes(g,id_to_state)
# node_values,new_id_to_state = minimax(g,node_map,id_to_state,node_values)
# write_mermaid(g,new_id_to_state)
# root = find_root_node(g)
# levels = map_node_levels(g, root)
# final_score = alpha_beta_recursive(g, node_values, root, -Inf, Inf, levels,id_to_state,print_name=true)
# println(final_score)


