include("dls.jl")
function ids(graph, mapping, start_node, end_nodes,depth_limit=100)
    depth = 0
    while true
        print("Searching with depth limit: ", depth,"=>")
        # Call your existing dls function
	result_found,path = dls(graph, mapping, start_node, end_nodes, depth)

        if  result_found
	    return true,path
        end
        depth += 1
        
        if depth > depth_limit 
            break 
        end
    end
    return false,[]
end


