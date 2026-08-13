U = fill(-0.04, 4, 6)

U[1, 2] = 1.0
U[1, 5] = -1.0

U[2, 2] = 0.0
U[2, 5] = 0.0
U[4, 3] = 0.0
U[4, 4] = 0.0

function interactive_environment(pos)
    cell_value = U[pos...]

    if cell_value == minimum(U) || cell_value == maximum(U)
        return (cell_value, true)
    else
        return (cell_value, false)
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

    max_rows, max_cols = size(U)

    if row >= 1 && row <= max_rows && col >= 1 && col <= max_cols
        if U[row, col] == 0.0
            return pos
        else
            return (row, col)
        end
    else
        return pos
    end
end
