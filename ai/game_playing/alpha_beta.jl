using Graphs,DataStructures
include("minimax.jl")
function alpha_beta_recursive(g, leaf_values, node_id, alpha, beta, node_levels, id_to_state; print_name=false)
    children = outneighbors(g, node_id)
    is_max = (node_levels[node_id] % 2 == 0)
    
    # Decide what to display based on the print_name flag
    display_name(id) = print_name ? id_to_state[id] : string(id)
    
    current_label = display_name(node_id)
    children_labels = [display_name(c) for c in children]
    
    # 1. BASE CASE: Leaf Node
    if isempty(children)
        val = leaf_values[node_id]
        println("Leaf Node $current_label: value = $val")
        return val
    end

    if is_max
        best_val = -Inf
        println("at $current_label (MAX) with children $children_labels")
        for child_id in children
            val = alpha_beta_recursive(g, leaf_values, child_id, alpha, beta, node_levels, id_to_state, print_name=print_name)
            best_val = max(best_val, val)
            alpha = max(alpha, best_val)
            
            if alpha >= beta
                println("  Pruning at child $(display_name(child_id)) of node $current_label")
                break
            end
        end
        return best_val
    else
        best_val = Inf
        println("at $current_label (MIN) with children $children_labels")
        for child_id in children
            val = alpha_beta_recursive(g, leaf_values, child_id, alpha, beta, node_levels, id_to_state, print_name=print_name)
            best_val = min(best_val, val)
            beta = min(beta, best_val)
            
            if alpha >= beta
                println("  Pruning at child $(display_name(child_id)) of node $current_label")
                break
            end
        end
        return best_val
    end
end
