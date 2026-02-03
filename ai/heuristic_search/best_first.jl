function greedy_best_first_search(map, start, goal)
    rows, cols = size(map)
    
    # Priority is now: (Manhattan, Global_Order, Direction_Order)
    pq = PriorityQueue{Tuple{Int,Int}, Tuple{Float64, Int, Int}}()
    
    visited = Set{Tuple{Int,Int}}()
    parent = Dict{Tuple{Int,Int}, Tuple{Int,Int}}()
    
    # Global counter to track when a node was added
    counter = 0

    counter += 1
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
                    
                    # Increment counter for every new discovery
                    counter += 1
                    
                    # Tie-break: Distance -> When it was added -> Which direction
                    priority = (map[neighbor...], counter, order_weight)
                    enqueue!(pq, neighbor => priority)
                end
            end
        end
    end
    return false, []
end

function greedy_best_first_search_graph(graph, mapping, heuristics, start_node, end_nodes)
    # 1. Setup indices and mappings
    start_idx = mapping[start_node]
    end_indices = Set(mapping[node] for node in end_nodes)
    reverse_mapping = Dict(v => k for (k, v) in mapping)
    
    # 2. Priority Queue: (Heuristic, Alphabetical_Order)
    # Using the name (String) for tie-breaking ensures alphabetical order
    pq = PriorityQueue{Int, Tuple{Int, String}}()
    
    visited = Set{Int}()
    parent = Dict{Int, Int}()
    
    # 3. Initialize
    # Priority is (h(n), "NodeName")
    enqueue!(pq, start_idx => (heuristics[start_idx], start_node))
    push!(visited, start_idx)

    while !isempty(pq)
        current = dequeue!(pq)
        current_name = reverse_mapping[current]
        print(current_name, " ")

        # 4. Goal Check
        if current in end_indices
            path = []
            curr = current
            while curr != start_idx
                pushfirst!(path, reverse_mapping[curr])
                curr = parent[curr]
            end
            pushfirst!(path, reverse_mapping[start_idx])
            println("\nGoal Found!")
            return true, path
        end

        # 5. Expand Neighbors
        # neighbors() returns children nodes from the graph
        for neighbor in neighbors(graph, current)
            if !(neighbor in visited)
                push!(visited, neighbor)
                parent[neighbor] = current
                
                neighbor_name = reverse_mapping[neighbor]
                h_val = heuristics[neighbor]
                
                # Priority: Smaller h(n) first, then alphabetical name
                enqueue!(pq, neighbor => (h_val, neighbor_name))
            end
        end
    end
    
    println("\nNo path found.")
    return false, []
end
