using Graphs,SimpleWeightedGraphs
function uniform_cost(graph,mapping,start_node,end_node)
    start_idx = mapping[start_node]
    end_idx = mapping[end_node]

    if start_idx == end_idx
	return true,[]
    end
    reverse_mapping = Dict(v => k for (k, v) in mapping)

    visited = Dict(idx => false for idx in values(mapping))
    cost = Dict(idx => Inf for idx in values(mapping))
    cost[start_idx] = 0

    parent = Dict{Int,Int}() 
    queue = [start_idx]
    optimal_path = []
    optimal_cost = Inf

    while !isempty(queue)
        current_node = popfirst!(queue)
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
	    
	    if cost[current_node] < optimal_cost
		optimal_cost = cost[current_node]
		optimal_path = path
	    end
	end
	children = neighbors(graph, current_node)
	unvisited_children = filter(child -> !visited[child], children)
	sort!(unvisited_children, by = child -> graph.weights[current_node,child])

	for child in unvisited_children
	    if !haskey(parent, child)
		parent[child] = current_node
	    end

	    current_parent = parent[child]
	    current_cost = cost[current_parent] + get_weight(graph,current_parent,child)
	    
	    if current_cost < cost[child]
		cost[child] = current_cost
	    end


	end
	append!(queue, unvisited_children)
	visited[current_node] = true
    end
    println()
    return !isempty(optimal_path),optimal_path
    

end
