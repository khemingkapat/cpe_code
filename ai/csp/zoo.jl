using Graphs
include("zoo_domains.jl")

const names = ["Julia", "Mary", "Alan", "Beth", "Tom"]
const GENDERS = ["Female", "Female", "Male", "Female", "Male"]

function is_boy(kid_idx)
    return GENDERS[kid_idx] == "Male"
end


function create_zoo_graph()
    num_kids = length(names)
    num_attributes = 4 # Last Name, Favorite, Hated, Snack
    
    # Initialize the graph with 20 nodes (5 kids * 4 attributes)
    graph = SimpleGraph(num_kids * num_attributes)
    
    # Create the node_map: (kid_idx, attr_idx) => Graph_Node_ID
    node_map = Dict{Tuple{Int, Int}, Int}()
    
    counter = 1
    for i in 1:num_kids
        for j in 1:num_attributes
            node_map[(i, j)] = counter
            counter += 1
        end
    end

    # --- ADD CONSTRAINTS (EDGES) ---

    # 1. All-Different Constraints (Internal category uniqueness)
    # For each attribute j, all kids i must have different values.
    for j in 1:num_attributes
        for i in 1:num_kids
            for k in (i + 1):num_kids
                add_edge!(graph, node_map[(i, j)], node_map[(k, j)])
            end
        end
    end

    # 2. Intra-Person Constraints (Linking attributes of the same kid)
    # Many clues link a kid's name, last name, and snack together.
    for i in 1:num_kids
        # Link Last Name (1) to Favorite (2), Hated (3), and Snack (4)
        add_edge!(graph, node_map[(i, 1)], node_map[(i, 2)])
        add_edge!(graph, node_map[(i, 1)], node_map[(i, 4)])
        # Link Favorite (2) to Hated (3)
        add_edge!(graph, node_map[(i, 2)], node_map[(i, 3)])
    end

    return graph,node_map
end

const attr_domains = [
    ["Procter", "Small", "Brown", "Cook", "Macgreger"], # 1: Last Name
    ["Monkey", "Giraffe", "Lion", "Seal", "Elephant"], # 2: Favorite
    ["Monkey", "Giraffe", "Lion", "Seal", "Elephant"], # 3: Hated
    ["Candy", "Apple", "Doughnut", "Popcorn", "Corn-chip"] # 4: Snack
]


# This function checks logic clues like "Brown likes Lion"
function is_logic_consistent!(kid_idx, attr_idx, val, domains, node_map, assign)
    # Define attribute IDs for clarity
    LAST_NAME = 1
    FAVORITE = 2
    HATED = 3
    SNACK = 4

    # --- CLUE 4: Brown liked Lion [cite: 154, 188] ---
    if attr_idx == LAST_NAME && val == "Brown"
        fav_node = node_map[(kid_idx, FAVORITE)]
        if !("Lion" in domains[fav_node]) return false end
        # Active Pruning: Force this kid's Favorite to be Lion
        intersect!(domains[fav_node], Set(["Lion"])) 
        
    elseif attr_idx == FAVORITE && val == "Lion"
        ln_node = node_map[(kid_idx, LAST_NAME)]
        if !("Brown" in domains[ln_node]) return false end
        intersect!(domains[ln_node], Set(["Brown"]))
    end

    # --- CLUE 5: Macgreger chose Doughnut [cite: 156, 190] ---
    if attr_idx == LAST_NAME && val == "Macgreger"
        snack_node = node_map[(kid_idx, SNACK)]
        if !("Doughnut" in domains[snack_node]) return false end
        intersect!(domains[snack_node], Set(["Doughnut"]))
        
    elseif attr_idx == SNACK && val == "Doughnut"
        ln_node = node_map[(kid_idx, LAST_NAME)]
        if !("Macgreger" in domains[ln_node]) return false end
        intersect!(domains[ln_node], Set(["Macgreger"]))
    end

    # --- CLUE 6: Cook liked Monkey  ---
    if attr_idx == LAST_NAME && val == "Cook"
        fav_node = node_map[(kid_idx, FAVORITE)]
        if !("Monkey" in domains[fav_node]) return false end
        intersect!(domains[fav_node], Set(["Monkey"]))
        
    elseif attr_idx == FAVORITE && val == "Monkey"
        ln_node = node_map[(kid_idx, LAST_NAME)]
        if !("Cook" in domains[ln_node]) return false end
        intersect!(domains[ln_node], Set(["Cook"]))
    end

    # --- GLOBAL RULE: Favorite and Hated cannot be the same for one kid [cite: 147, 181] ---
    if attr_idx == FAVORITE
        hated_node = node_map[(kid_idx, HATED)]
        delete!(domains[hated_node], val) # If I love Lion, I cannot hate Lion
        if isempty(domains[hated_node]) return false end
    elseif attr_idx == HATED
        fav_node = node_map[(kid_idx, FAVORITE)]
        delete!(domains[fav_node], val) # If I hate Lion, I cannot love Lion
        if isempty(domains[fav_node]) return false end
    end

    return true
end

function solve_zoo_csp(g, node_map, domains, assign=nothing)
    # Initialize assignments if this is the root call
    if isnothing(assign)
        assign = Dict{Int, Union{String, Nothing}}(n => nothing for n in vertices(g))
    end

    # 1. Check if we are done: Are all nodes assigned?
    if all(!isnothing(v) for v in values(assign))
        return assign
    end

    # 2. MRV Heuristic: Pick the unassigned node with the smallest domain [cite: 165, 217]
    unassigned_nodes = [n for n in vertices(g) if isnothing(assign[n])]
    current = sort(unassigned_nodes, by = n -> length(domains[n]))[1]

    # Reverse map current node_id back to (kid, attr) for logic checks
    current_coord = filter(p -> p.second == current, node_map)
    kid_idx, attr_idx = first(keys(current_coord))

    # 3. Try values in the domain
    sorted_values = sort(collect(domains[current]))
    
    for val in sorted_values
        # Create a "snapshot" of the current state to allow backtracking
        local_domains = deepcopy(domains)
        local_assign = copy(assign)

        # A. Apply Active Logic (e.g., Brown forced to Lion)
        if !is_logic_consistent!(kid_idx, attr_idx, val, local_domains, node_map, local_assign)
            continue
        end

        # B. Apply Assignment
        local_assign[current] = val
        local_domains[current] = Set([val])

        # C. Forward Checking: Prune neighbors [cite: 24, 246]
        # For All-Different constraints (same attribute category)
        is_fc_safe = true
        for neighbor in neighbors(g, current)
            if isnothing(local_assign[neighbor])
                # Check if they are in the same attribute category
                neighbor_coord = filter(p -> p.second == neighbor, node_map)
                _, n_attr_idx = first(keys(neighbor_coord))
                
                if n_attr_idx == attr_idx
                    delete!(local_domains[neighbor], val)
                    if isempty(local_domains[neighbor])
                        is_fc_safe = false
                        break
                    end
                end
            end
        end

        # D. Recurse: If forward checking is safe, go deeper
        if is_fc_safe
            println("Assigned $(names[kid_idx]) -> $val. Moving to next...")
            result = solve_zoo_csp(g, node_map, local_domains, local_assign)
            
            if result != "Fail"
                return result # Success!
            end
        end
        
        # If we reach here, the current 'val' led to a failure. 
        # The loop will try the next value (Backtracking).
        println("Backtracking from $(names[kid_idx]) = $val")
    end

    return "Fail"
end
