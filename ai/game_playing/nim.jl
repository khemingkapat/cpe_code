using Graphs

function create_nim(pillars...)
    k = length(pillars)
    
    # We now map (State, Path) -> Unique ID
    node_map = Dict{Tuple, Int}()
    id_to_state = Dict{Int, Tuple}()
    g = SimpleDiGraph()

    # Initial state now includes an empty path (represented by an empty tuple)
    # State format: (p1, p2, ..., player, path_history)
    initial_state = (pillars..., :A, ()) 

    add_vertex!(g)
    node_map[initial_state] = 1
    id_to_state[1] = initial_state

    queue = [1]
    head = 1

    while head <= length(queue)
        current_id = queue[head]
        current_state = id_to_state[current_id]
        head += 1

        piles = current_state[1:k]
        current_p = current_state[k+1]
        path_history = current_state[k+2]
        
        next_p = (current_p == :A) ? :B : :A

        if all(piles .== 0)
            continue
        end

        for i in 1:k
            for count in 1:piles[i]
                next_piles_list = collect(piles)
                next_piles_list[i] -= count
                
                # We record this specific move: (which_pile, how_many)
                current_move = (i, count)
                # Create a new path by adding this move to the old history
                new_path = (path_history..., current_move)
                
                # The state is now unique because the path is part of it
                next_state = (Tuple(next_piles_list)..., next_p, new_path)
                
                # This will ALWAYS be true now for different sequences
                if !haskey(node_map, next_state)
                    add_vertex!(g)
                    new_id = nv(g)
                    node_map[next_state] = new_id
                    id_to_state[new_id] = next_state
                    push!(queue, new_id)
                end
                
                add_edge!(g, current_id, node_map[next_state])
            end
        end
    end
    return g, node_map, id_to_state
end
