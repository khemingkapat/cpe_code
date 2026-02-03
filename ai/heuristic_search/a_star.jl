function a_star(map, start, goal)
    rows, cols = size(map)
    pq = PriorityQueue{Tuple{Int,Int},Tuple{Float64,Int,Int}}()
    visited = Set{Tuple{Int,Int}}()
    parent = Dict{Tuple{Int,Int},Tuple{Int,Int}}()
    counter = 1
    enqueue!(pq, start => (map[start...], counter, 0))
    push!(visited, start)

    while !isempty(pq)
        current = dequeue!(pq)
        println(current)
        if current == goal
            path = []
            curr = goal
            while curr != start
                pushfirst!(path, curr)
                curr = parent[curr]
            end
            pushfirst!(path, start)
            return true, path
        end

        dirs = [
            ((-1, 0), 1), # Up
            ((0, -1), 2), # Left
            ((0, 1), 3),  # Right
            ((1, 0), 4)   # Down
        ]

        for ((di, dj), order_weight) in dirs
            neighbor = (current[1] + di, current[2] + dj)
            if neighbor[1] in 1:rows && neighbor[2] in 1:cols
                if map[neighbor...] != Inf && !(neighbor in visited)
                    push!(visited, neighbor)
                    parent[neighbor] = current
                    counter += 1
                    priority = (map[neighbor...], counter, order_weight)
                    enqueue!(pq, neighbor => priority)
                end
            end
        end
    end
    return false, []
end

function a_star_graph(graph, mapping, heuristics, start_node, end_nodes, cutoff=-1.0)
    start_idx = mapping[start_node]
    end_indices = Set(mapping[node] for node in end_nodes)
    reverse_mapping = Dict(v => k for (k, v) in mapping)
    
    # Priority Queue for f_score: f(n) = g(n) + h(n)
    pq = PriorityQueue{Int, Float64}() 
    g_score = Dict{Int, Float64}()
    g_score[start_idx] = 0.0
    parent = Dict{Int, Int}()
    
    # Initial heuristic check
    if cutoff >= 0 && heuristics[start_idx] > cutoff
        return false, []
    end

    enqueue!(pq, start_idx => (g_score[start_idx] + heuristics[start_idx]))

    while !isempty(pq)
        current = dequeue!(pq)

        print(reverse_mapping[current], ",")
        
        # Goal Check
        if current in end_indices
            path = []
            curr = current
            while curr != start_idx
                pushfirst!(path, reverse_mapping[curr])
                curr = parent[curr]
            end
	    println()
            pushfirst!(path, reverse_mapping[start_idx])
            return true, path
        end

        for neighbor in neighbors(graph, current)
            # Heuristic Cutoff Check
            if cutoff >= 0 && heuristics[neighbor] > cutoff
                continue
            end

            edge_weight = weights(graph)[current, neighbor]
            tentative_g = g_score[current] + edge_weight

            if !haskey(g_score, neighbor) || tentative_g < g_score[neighbor]
                parent[neighbor] = current
                g_score[neighbor] = tentative_g
                f_score = tentative_g + heuristics[neighbor]
                pq[neighbor] = f_score
            end
        end
    end
    
    return false, []
end

function ida_star_graph(graph, mapping, heuristics, start_node, end_nodes)
    unique_h_values = sort(unique(values(heuristics)))
    
    for current_cutoff in unique_h_values
        println("Checking with heuristic cutoff: ", current_cutoff)
        
        found, path = a_star_graph(graph, mapping, heuristics, start_node, end_nodes, current_cutoff)
        
        if found
            println("Path found at cutoff ", current_cutoff)
            return found,path
        end
    end
    
    return false,nothing
end
