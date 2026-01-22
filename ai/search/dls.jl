function dls(graph, mapping, start_node, end_node, limit=-1)
    start_idx = mapping[start_node]
    end_idx = mapping[end_node]
    reverse_mapping = Dict(v => k for (k, v) in mapping)

    fringe = [start_idx]
    depth_stack = [0]
    visited = Dict(idx => false for idx in values(mapping))
    
    parent = Dict{Int,Int}() 

    while !isempty(fringe)
        current_node = popfirst!(fringe)
        node_depth = popfirst!(depth_stack)
        
        if visited[current_node]
            continue
        end

	print(reverse_mapping[current_node],",")

        if current_node == end_idx
            path = []
            curr = end_idx
            while curr != start_idx
                pushfirst!(path, reverse_mapping[curr])
                curr = parent[curr]
            end
            pushfirst!(path, reverse_mapping[start_idx])
	    println()
            return true,path
        end

        visited[current_node] = true
       
        if (limit >= 0) && (node_depth >= limit)
            continue
        end

       children = neighbors(graph, current_node)
        unvisited_children = filter(child -> !visited[child], children)

	for child in unvisited_children
	    if !haskey(parent, child)
		parent[child] = current_node
	    end
	end
        prepend!(fringe, unvisited_children)
        prepend!(depth_stack, fill(node_depth + 1, length(unvisited_children)))
    end
    println()
    return false,[] # Return nothing if no path is found
end
