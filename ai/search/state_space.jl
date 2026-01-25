function is_safe(state)
    cats_l, dogs_l, boat = state
    cats_r = 2 - cats_l
    dogs_r = 2 - dogs_l

    if cats_l > 0 && dogs_l > cats_l; return false end
    if cats_r > 0 && dogs_r > cats_r; return false end
    return true
end

function S(state, c, d)
    cats_l, dogs_l, boat = state
    if boat == 0
        cats_l - c < 0 || dogs_l - d < 0 && return false, nothing
        new_state = (cats_l - c, dogs_l - d, 1)
    else
        cats_r = 2 - cats_l
        dogs_r = 2 - dogs_l
        c > cats_r || d > dogs_r && return false, nothing
        new_state = (cats_l + c, dogs_l + d, 0)
    end

    return is_safe(new_state), new_state
end

function formulate_state_space!(state_space, node_map)
    for current_state in keys(node_map)
        u = node_map[current_state]
        for c in 0:2, d in 0:2
            if 1 <= (c + d) <= 2
                success, next_state = S(current_state, c, d)
                if success && haskey(node_map, next_state)
                    v = node_map[next_state]
                    weight_val = Float64((c * 10) + d)
                    add_edge!(state_space, u, v, weight_val)
                end
            end
        end
    end
end

function create_possible_states()
    node_map = Dict()
    current_idx = 1
    for c in 0:2, d in 0:2, b in 0:1
        if is_safe((c, d, b))
            node_map[(c, d, b)] = current_idx
            current_idx += 1
        end
    end
    return node_map
end

function create_state_space()
    node_map = create_possible_states()
    state_space = SimpleWeightedDiGraph(length(node_map))
    formulate_state_space!(state_space, node_map)
    return state_space, node_map
end
