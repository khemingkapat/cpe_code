include("map.jl")
include("transition_model.jl")

function get_next_state(U, current_pos, action)
    row,col = current_pos

    new_row, new_col = row,col

    if action == :up
        new_row -= 1
    elseif action == :down
        new_row += 1
    elseif action == :left
        new_col -= 1
    elseif action == :right
        new_col += 1
    end

    if new_col >= 1 && new_col <= 3 && new_row >= 1 && new_row <= 3
	return (new_row,new_col)
    else
        return current_pos
    end
end

function update_cell(U, pos, trans_model=trans_model, reward=-0.04)
    row,col = pos

    if (row == 2 && col == 2) return -1.0, :none end
    if (row == 2 && col == 3) return  1.0, :none end

    best_expected_utility = -Inf
    best_expected_action  = nothing

    for (action, outcomes) in trans_model
        current_action_expected_utility = 0.0
        for (direction, prob) in outcomes
            next_row, next_col = get_next_state(U, pos, direction)
            current_action_expected_utility += prob * U[next_row, next_col]
        end
	println("\twith action going $(action), EU($(action))=$(round(current_action_expected_utility,digits=3))")

        if current_action_expected_utility > best_expected_utility
            best_expected_utility = current_action_expected_utility
            best_expected_action  = action
        end
    end

    return (reward + best_expected_utility, best_expected_action)
end

function run_iteration(U, start_pos,trans_model, policy,terminals)
    new_U      = copy(U)
    new_Policy = copy(policy)

    current_pos = start_pos

    while(!(current_pos in terminals))
	println("currently at $(current_pos) with current value as $(round(new_U[current_pos...],digits=3)) ")
        new_val, best_action = update_cell(new_U, current_pos, trans_model)
	new_U[current_pos...]      = round(new_val,digits=3)
	new_Policy[current_pos...] = best_action
	println("then, with values current value is $(round(new_val,digits=3)),then best action is to go $(best_action)")

	current_pos = get_next_state(new_U,current_pos,best_action)
    end
    return new_U, new_Policy
end

terminals = [(2, 2), (2,3)]

function run_value_iteration(U_initial,start_pos, trans_model, terminals, k)
    current_U = U_initial
    policy = fill(:none, size(U_initial))

    for i in 1:k
        println("\n" * "="^30)
        println("Iteration $i")
        println("="^30)

        current_U, policy = run_iteration(current_U,start_pos, trans_model,policy, terminals)

        println("\nUtility Matrix (U):")
        display(current_U)

        println("\nPolicy Matrix (Best Actions):")
        display(policy)
    end

    return current_U, policy
end

run_value_iteration(U,(2,1), trans_model, terminals, 2)
