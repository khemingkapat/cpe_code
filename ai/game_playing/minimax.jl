using Graphs,DataStructures
function find_leaf_nodes(graph)
    leaves = Int[]
    
    for v in vertices(graph)
        if outdegree(graph, v) == 0
            push!(leaves, v)
        end
    end
    
    return leaves
end

function find_root_node(graph)
    for v in vertices(graph)
        if indegree(graph, v) == 0
	    return v
        end
    end
    
end

function map_node_levels(graph, root_id=1)
    node_levels = Dict{Int, Int}()
    
    queue = [(root_id, 0)]
    node_levels[root_id] = 0
    
    head = 1
    while head <= length(queue)
        curr_id, curr_depth = queue[head]
        head += 1
        
        for neighbor in outneighbors(graph, curr_id)
            if !haskey(node_levels, neighbor)
                node_levels[neighbor] = curr_depth + 1
                push!(queue, (neighbor, curr_depth + 1))
            end
        end
    end
    
    return node_levels
end
function minimax(g, node_map, id_to_state)
    root_id = find_root_node(g)
    node_levels = map_node_levels(g, root_id)
    leaves = find_leaf_nodes(g)

    node_values = Dict{Int, Int}()
    new_id_to_state = Dict{Int, Tuple}()
    
    all_nodes = collect(vertices(g))
    sort!(all_nodes, by = n -> node_levels[n], rev = true)

    for curr_node in all_nodes
        state_info = id_to_state[curr_node]
        
        if curr_node in leaves
            player = state_info[end-1] 
            val = (player == :A) ? -1 : 1
            node_values[curr_node] = val
        else
            children_values = [node_values[child] for child in outneighbors(g, curr_node)]
            
            if node_levels[curr_node] % 2 == 0
                val = maximum(children_values)
            else
                val = minimum(children_values)
            end
            node_values[curr_node] = val
        end

        
        new_id_to_state[curr_node] = (state_info[1:end-1]..., val, state_info[end])
    end

    return node_values, new_id_to_state
end
