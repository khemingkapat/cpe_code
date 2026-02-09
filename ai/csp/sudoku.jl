using Graphs

function create_sudoku()
    node_map = Dict{Tuple{Int,Int},Int}()
    graph = SimpleGraph(16)
    
    for r in 1:4, c in 1:4
        node_map[(r, c)] = (r - 1) * 4 + c
    end

    # 2. Add edges
    for r1 in 1:4, c1 in 1:4
        for r2 in 1:4, c2 in 1:4
            if r1 == r2 && c1 == c2
                continue
            end

            u = node_map[(r1, c1)]
            v = node_map[(r2, c2)]

            same_row = (r1 == r2)
            same_col = (c1 == c2)
            same_grid = (div(r1-1, 2) == div(r2-1, 2) && div(c1-1, 2) == div(c2-1, 2))

            if same_row || same_col || same_grid
                add_edge!(graph, u, v)
            end
        end
    end
    return graph
end
