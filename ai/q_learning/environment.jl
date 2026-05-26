U = fill(-1.0, 3, 3)
U[2, 2] = -10.0
U[2, 3] = 10.0

function interactive_environment(pos)
    if (U[pos...] != -1)
        return (U[pos...], true)
    else
        return (U[pos...], false)
    end
end

function get_next_state(pos, action)
    row, col = pos
    if action == :up
        row -= 1
    elseif action == :down
        row += 1
    elseif action == :left
        col -= 1
    elseif action == :right
        col += 1
    end

    if col >= 1 && col <= 3 && row >= 1 && row <= 3
        return (row, col)
    else
        return pos
    end
end
