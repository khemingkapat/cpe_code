include("dls.jl")
function ids(graph, mapping, start_node, end_node)
    depth = 0
    while true
        println("Searching with depth limit: ", depth)
        # Call your existing dls function
        if dls(graph, mapping, start_node, end_node, depth)
            return true
        end
        depth += 1
        
        # if depth > 100 
        #     break 
        # end
    end
    return false
end

