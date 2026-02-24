using Graphs

function write_mermaid(graph, id_to_label)
    println("graph TD")
    
    # 1. Define Nodes with Labels
    for node in vertices(graph)
        full_state = id_to_label[node]
        
        # REMOVE PATH: We only take the piles and the player (indices 1 to k+1)
        # This way, the label looks like (3, 2, :A) even if the node is unique
	clean_label = full_state[1:end-1]
        
        label_text = string(clean_label)
        
        # Syntax: N1["Label Text"]
        println("\tN$node[\"$label_text\"]")
    end

    println() 

    # 2. Define Connections (Edges)
    for e in edges(graph)
        u, v = src(e), dst(e)
        println("\tN$u --> N$v")
    end
end
