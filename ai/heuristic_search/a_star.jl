 include("create_map.jl")

function a_star(map, start, goal)
    rows, cols = size(map)
    pq = PriorityQueue{Tuple{Int,Int}, Tuple{Float64, Int, Int}}()
    visited = Set{Tuple{Int,Int}}()
    parent = Dict{Tuple{Int,Int}, Tuple{Int,Int}}()
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


