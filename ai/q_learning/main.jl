include("environment.jl")

alpha = 0.1
gamma = 0.9

rows, cols = size(U)

actions = [:up, :left, :right, :down]
Q = Dict()
for r in 1:rows, c in 1:cols, act in actions
    Q[((r, c), act)] = 0.0
end

function get_max_q(state)
    max_val = -Inf
    for act in actions
        if Q[(state, act)] > max_val
            max_val = Q[(state, act)]
        end
    end
    return max_val
end

function get_best_action(state)
    best_act = actions[1]
    max_val = -Inf
    for act in actions
        if Q[(state, act)] > max_val
            max_val = Q[(state, act)]
            best_act = act
        end
    end
    return best_act
end

function update_cell(pos, action)
    next_pos = get_next_state(pos, action)
    reward, is_terminal = interactive_environment(next_pos)
    current_q = Q[(pos, action)]
    if is_terminal
        target = reward
    else
        target = reward + gamma * get_max_q(next_pos)
    end
    Q[(pos, action)] = current_q + alpha * (target - current_q)
    return next_pos, is_terminal
end

function run_episode(start_pos)
    pos = start_pos
    _, is_terminal = interactive_environment(pos)

    if is_terminal
        return
    end

    while !is_terminal
        action = get_best_action(pos)
        pos, is_terminal = update_cell(pos, action)
    end
end
function print_policy()
    arrows = Dict(:up => "^", :down => "v", :left => "<", :right => ">")

    for r in 1:rows
        for c in 1:cols
            if U[r, c] == 0.0
                print("[w] ") # Print [W] for Wall cells
                continue
            end

            reward, is_terminal = interactive_environment((r, c))
            if is_terminal
                if reward > 0
                    print("[G] ") # Goal
                else
                    print("[X] ") # Trap
                end
            else
                best_act = get_best_action((r, c))
                print(" $(arrows[best_act])  ")
            end
        end
        println()
    end
    println("-"^20)
end


function run_episodes(start_pos, k, step=100)
    println("Policy Grid at Start")
    print_policy()
    for episode in 1:k
        run_episode(start_pos)

        if episode % step == 0
            println("Policy Grid after Episode $episode:")
            print_policy()
        end
    end
end

run_episodes((4, 2), 1000)
