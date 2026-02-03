function bfs(graph, mapping, start_node, end_nodes)
    start_idx = mapping[start_node]
    end_indices = Set(mapping[node] for node in end_nodes)
    
    reverse_mapping = Dict(v => k for (k, v) in mapping)

    fringe = [start_idx]
    visited = Dict(idx => false for idx in values(mapping))
    parent = Dict{Int,Int}() 

    while !isempty(fringe)
        current_node = popfirst!(fringe)
        
        if visited[current_node]
            continue
        end
    
        print(reverse_mapping[current_node], ",")

        if current_node in end_indices
            path = []
            curr = current_node
            while curr != start_idx
                pushfirst!(path, reverse_mapping[curr])
                curr = parent[curr]
            end
            pushfirst!(path, reverse_mapping[start_idx])
            println()
            return true, path
        end

        visited[current_node] = true
        
        children = neighbors(graph, current_node)
        
        unvisited_children = filter(child -> !visited[child], children)
        sort!(unvisited_children, by=child -> reverse_mapping[child]) 

        for child in unvisited_children
            if !haskey(parent, child)
                parent[child] = current_node
                push!(fringe, child)
            end
        end
    end
    println()
    return false, [] 
end
