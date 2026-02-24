using Plots, GraphRecipes

include("nim.jl")
include("minimax.jl")
include("visualize.jl")
include("alpha_beta.jl")
g, node_map, id_to_state = create_nim(2, 1, 1)
node_values = assign_leaf_nodes(g,id_to_state)
node_values, new_id_to_state = minimax(g, node_map, id_to_state,node_values)
alpha_beta_pruning(g, new_id_to_state)



