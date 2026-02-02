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
