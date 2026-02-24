using Graphs
function write_mermaid(graph, id_to_label)
    println("graph TD")
    
    # 1. Define Nodes with Labels
    # We use "N" + ID to ensure the internal name is a valid Mermaid identifier
    for node in vertices(graph)
        label = haskey(id_to_label, node) ? string(id_to_label[node]) : "Node $node"
        
        # Syntax: N1["Label Text"]
        println("\tN$node[\"$label\"]")
    end

    println() # Clear separation for readability

    # 2. Define Connections (Edges)
    for e in edges(graph)
        u, v = src(e), dst(e)
        
        # Syntax: N1 --> N2
        println("\tN$u --> N$v")
    end
end
