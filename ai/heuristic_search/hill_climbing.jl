function hill_climbing(h_map, start, goal)
    rows, cols = size(h_map)
    current = start
    path = [current]
    
    while current != goal
        current_h = h_map[current...]
        
        dirs = [
            (-1, 0), # Up
            (0, -1), # Left
            (0, 1),  # Right
            (1, 0)   # Down
        ]
        
        best_neighbor = nothing
        best_h = current_h
        
        for (di, dj) in dirs
            neighbor = (current[1] + di, current[2] + dj)
            
            if neighbor[1] in 1:rows && neighbor[2] in 1:cols && h_map[neighbor...] != Inf
                neighbor_h = h_map[neighbor...]
                
                if neighbor_h < best_h
                    best_h = neighbor_h
                    best_neighbor = neighbor
                end
            end
        end
        
        if best_neighbor === nothing
            break
        else
            current = best_neighbor
            push!(path, current)
            println(current)
        end
    end
    
    if current == goal
	return true, path
    else
	return false,nothing
    end
end
