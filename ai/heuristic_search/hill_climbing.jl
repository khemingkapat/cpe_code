function hill_climbing(h_map, start, goal)
    rows, cols = size(h_map)
    
    fringe = [start]
    
    visited = Set{Tuple{Int,Int}}()
    parent = Dict{Tuple{Int,Int}, Tuple{Int,Int}}()
    
    while !isempty(fringe)
        current = pop!(fringe)
        
        if current in visited
            continue
        end
        
        println(current)
        push!(visited, current)

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

        raw_dirs = [
            (1, 0),  # Down
            (0, 1),  # Right
            ((0, -1)), # Left
            (-1, 0)  # Up
        ]

        neighbors_to_add = []
        for (di, dj) in raw_dirs
            neighbor = (current[1] + di, current[2] + dj)
            if neighbor[1] in 1:rows && neighbor[2] in 1:cols
                if h_map[neighbor...] != Inf && !(neighbor in visited)
                    push!(neighbors_to_add, neighbor)
                end
            end
        end

        sort!(neighbors_to_add, by = n -> h_map[n...], rev = true)

        for neighbor in neighbors_to_add
            if !haskey(parent, neighbor)
                parent[neighbor] = current
            end
            push!(fringe, neighbor)
        end
    end

    return false, []
end
