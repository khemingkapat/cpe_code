include("map.jl")
include("transition_model.jl")

function get_next_state(U, current_pos, action)
    row,col = current_pos
    
    new_col, new_row = col, row
    
    if action == :up
        new_row -=1
    elseif action == :down
        new_row +=1
    elseif action == :left
        new_col -= 1
    elseif action == :right
        new_col += 1
    end
    
    if new_col >= 1 && new_col <= 3 && new_row >= 1 && new_row <= 3
        return (new_col, new_row)
    else
        return current_pos
    end
end

function update_cell(U, pos, trans_model=trans_model, reward=-0.04)
    row,col = pos
    
    # Check for terminal states (they never change)
    if (col == 2 && row == 2) return -1.0 end
    if (col == 3 && row == 2) return 1.0 end
    
    best_expected_utility = -Inf
    best_expected_action = nothing
    
    for (action, outcomes) in trans_model
        current_action_expected_utility = 0.0
        for (direction, prob) in outcomes
	    next_state = get_next_state(U,pos,direction)
	    next_row,next_col = next_state
	    current_action_expected_utility += prob * U[next_row,next_col]
        end
        
        if current_action_expected_utility > best_expected_utility
            best_expected_utility = current_action_expected_utility
	    best_expected_action = action
        end
    end

    return (reward + best_expected_utility,best_expected_action)
end

# 1. Function to perform one full iteration over all cells
function run_iteration(U, trans_model, terminals)
    new_U = copy(U)
    new_Policy = fill(:none, size(U)) # Store the best action for each cell
    
    # Grid dimensions (3x3)
    rows, cols = size(U)
    
    for r in 1:rows
        for c in 1:cols
            # Skip if this is a terminal state
            if (c, r) in terminals
                continue
            end
            
            # Perform update (Passing as (r, c) to match your update_cell logic)
            new_val, best_action = update_cell(U, (r, c), trans_model)
            
            new_U[r, c] = new_val
            new_Policy[r, c] = best_action
        end
    end
    
    return new_U, new_Policy
end

terminals = [(2, 2), (3, 2)]

function run_value_iteration(U_initial, trans_model, terminals, k)
    current_U = U_initial
    policy = nothing
    
    # Run the loop k times
    for i in 1:k
        println("\n" * "="^30)
        println("Iteration $i")
        println("="^30)
        
        # Perform one full sweep across the grid
        current_U, policy = run_iteration(current_U, trans_model, terminals)
        
        println("\nUtility Matrix (U):")
        display(current_U)
        
        println("\nPolicy Matrix (Best Actions):")
        display(policy)
    end
    
    return current_U, policy
end

run_value_iteration(U, trans_model, terminals, 2)

