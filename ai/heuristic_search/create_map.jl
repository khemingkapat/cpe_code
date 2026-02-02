function create_blank_map(n)
    return zeros(n, n)
end

function add_walls!(map, walls)
    for (i, j) in walls
        map[i, j] = Inf
    end
    return map
end

function add_manhattan!(map, goal)
    goal_i, goal_j = goal
    rows, cols = axes(map)

    for j in cols, i in rows
        if map[i, j] != Inf
            map[i, j] = abs(i - goal_i) + abs(j - goal_j)
        end
    end
    return map
end

