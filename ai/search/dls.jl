function dls(graph, mapping, start_node, end_node,limit=-1)
    start_idx = mapping[start_node]
    end_idx = mapping[end_node]
    reverse_mapping = Dict(v => k for (k, v) in mapping)

    fringe = [start_idx]
    depth_stack = [0]
    visited = Dict(idx => false for idx in values(mapping))
    current_depth = 1

    while !isempty(fringe)
        current_node = popfirst!(fringe)
	node_depth = popfirst!(depth_stack)
        
        if visited[current_node]
            continue
        end

        println(reverse_mapping[current_node])
        
        if current_node == end_idx
            return true
        end

        visited[current_node] = true
       
	if (limit > 0) && (node_depth > limit)
	    continue
	end

        children = neighbors(graph, current_node)
	current_depth += 1
        unvisited_children = filter(child -> !visited[child], children)

        prepend!(fringe, unvisited_children)
	prepend!(depth_stack,fill(current_depth,length(unvisited_children)))
    end
    
    return false
end
