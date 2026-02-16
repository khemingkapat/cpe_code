using Graphs
using DataStructures

function create_adjacency_graph()
    g = SimpleGraph(6)

    add_edge!(g,1,3)
    add_edge!(g,1,6)
    add_edge!(g,2,4)
    add_edge!(g,2,5)
    add_edge!(g,3,4)
    add_edge!(g,3,5)
    add_edge!(g,3,6)
    add_edge!(g,4,5)
    add_edge!(g,5,6)

    return g
end

function backtracking_search(g, vars::Vector{String})
    assign = Dict{Int, Union{String, Nothing}}(n => nothing for n in vertices(g))
    nodes = collect(vertices(g))
    tried_values = Dict{Int, Set{String}}(n => Set{String}() for n in vertices(g))

    index = 1
    instances = 0 # Initialize counter
    
    while index <= length(nodes) && index > 0
        instances += 1
        node = nodes[index]
        
        # 1. Identify constraints from neighbors
        used_by_neighbors = Set{String}()
        for neighbor in neighbors(g, node)
            if !isnothing(assign[neighbor])
                push!(used_by_neighbors, assign[neighbor])
            end
        end

        # 2. Find remaining options
        available_options = setdiff(vars, used_by_neighbors, tried_values[node])
        sorted_options = sort(collect(available_options), by = v -> findfirst(==(v), vars))

        if !isempty(sorted_options)
            choice = sorted_options[1]
            
            # PRINT: Tracking the successful assignment
            println("Step $instances: Node $node assigned $choice (Neighbors use: $(collect(used_by_neighbors)))")
            
            assign[node] = choice
            push!(tried_values[node], choice)
            index += 1
        else
            # PRINT: Tracking the failure and backtracking
            println("Step $instances: Node $node has NO options. Backtracking from index $index...")
            
            assign[node] = nothing
            tried_values[node] = Set{String}() # Reset trials for this node
            index -= 1
            
            if index > 0
                prev_node = nodes[index]
                println("  Returning to Node $prev_node (previous value was $(assign[prev_node]))")
            end
        end
    end
    
    if index == 0
        println("Search failed: No solution exists.")
        return nothing
    end

    println("Search successful in $instances steps.")
    return assign
end

function forward_checking(g,vars,pre_assign=nothing)
    if isnothing(pre_assign)
        assign = Dict{Int, Union{String, Nothing}}(n => nothing for n in vertices(g))
    else
        assign = copy(pre_assign)
    end

    domains = Dict{Int, Set{String}}(n => Set(vars) for n in vertices(g))

    for n in vertices(g)
        if !isnothing(assign[n])
            current_color = assign[n]
            for neighbor in neighbors(g, n)
                delete!(domains[neighbor], current_color)
            end
        end
    end

    pq = PriorityQueue{Int, Tuple{Int, Int}}()
    for n in vertices(g)
        if isnothing(assign[n])
            pq[n] = (length(domains[n]), n)
        end
    end
    stack = Int[]
    
    while !isempty(pq) || !isempty(stack)
	if isempty(pq) return assign end

	current = peek(pq).first # Look at the best node
	available_options = sort(collect(domains[current]), by=v -> findfirst(==(v), vars))
	current_neighbors = [n for n in neighbors(g, current) if isnothing(assign[n])]

	found_valid = false
	println("current at $current")
	for opt in available_options
	    is_valid = true
	    for nb in current_neighbors
                if !isnothing(assign[nb])
		    continue
                end
		neighbor_domain = setdiff(domains[nb],Set([opt]))
		println("\ttry $current to be $opt and check with $nb")
		if isempty(neighbor_domain)
		    is_valid=false
		    break
		end
            end
	    if is_valid
		found_valid = true
		assign[current] = opt
		dequeue!(pq)
		for neighbor in current_neighbors
		    domains[neighbor] = setdiff(domains[neighbor],Set([opt]))
		    pq[neighbor] = (length(domains[neighbor]),neighbor)
		end
		push!(stack,current)
		break
	    else
		delete!(domains[current], opt)
	    end
	end
	if !found_valid
            if isempty(stack) return nothing end # Totally stuck
            prev_node = pop!(stack)
	    prev_opt = assign[prev_node]
            println("Backtracking from $prev_node...")
	    for neighbor in neighbors(g,current)
		push!(domains[neighbor], prev_opt)
		pq[neighbor] = (length(domains[neighbor]), neighbor)
	    end
            assign[prev_node] = nothing
            delete!(domains[prev_node], prev_opt)
            pq[prev_node] = length(domains[prev_node])
        end

    end
    return assign
end

function check_adjacency_assignment(g,assign)
    for node in vertices(g)
	current_assignment = assign[node]
	for neighbor in neighbors(g,node)
	    if assign[neighbor] == current_assignment
		return false
	    end
	end
    end
    return true
end
