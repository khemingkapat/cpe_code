using Graphs,DataStructures
include("minimax.jl")

function alpha_beta_pruning(g, id_to_state)
    root_id = find_root_node(g)
    node_levels = map_node_levels(g, root_id)

    stack = [(root_id, -Inf, Inf, 1, 0.0)]
    
    results = Dict{Int,Float64}()

    while !isempty(stack)
        node_id, alpha, beta, child_idx, best_val = stack[end]
        children = outneighbors(g, node_id)
        is_max = (node_levels[node_id] % 2 == 0)

	println("at node $node_id, and children are $(children)")

        if isempty(children)
            results[node_id] = Float64(id_to_state[node_id][end])
            pop!(stack)
            continue
        end

        if child_idx == 1
            best_val = is_max ? -Inf : Inf
        end


        # 3. Check if we have more children to visit
        if child_idx <= length(children)
            child_id = children[child_idx]
            
            stack[end] = (node_id, alpha, beta, child_idx + 1, best_val)

            # If the child's result is already known, update best_val
            if haskey(results, child_id)
                child_res = results[child_id]
                if is_max
                    best_val = max(best_val, child_res)
                    alpha = max(alpha, best_val)
                else
                    best_val = min(best_val, child_res)
                    beta = min(beta, best_val)
                end
                
                # Update best_val in the stack entry
                stack[end] = (node_id, alpha, beta, child_idx + 1, best_val)

                # ALPHA-BETA PRUNING CUTOFF
                if alpha >= beta
                    results[node_id] = best_val
            end
            else
                # Push the child onto the stack to visit it (DFS order)
                push!(stack, (child_id, alpha, beta, 1, 0.0))
            end
        else
            results[node_id] = best_val
            pop!(stack)
        end
    end

    return results[root_id]
end
