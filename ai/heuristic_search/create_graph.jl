function create_graph()
    nodes = ["A", "B", "C", "D", "E", "F", "G1", "G2", "G3", "S"]
    
    node_map = Dict(name => i for (i, name) in enumerate(nodes))
    
    heuristics = zeros(Int, length(nodes))
    heuristics[node_map["A"]] = 9
    heuristics[node_map["B"]] = 1
    heuristics[node_map["C"]] = 3
    heuristics[node_map["D"]] = 4
    heuristics[node_map["E"]] = 1
    heuristics[node_map["F"]] = 5
    heuristics[node_map["G1"]] = 0
    heuristics[node_map["G2"]] = 0
    heuristics[node_map["G3"]] = 0
    heuristics[node_map["S"]] = 8

    g = SimpleWeightedDiGraph(length(nodes))
    
    add_edge!(g, node_map["S"], node_map["A"], 3)
    add_edge!(g, node_map["S"], node_map["B"], 1)
    add_edge!(g, node_map["S"], node_map["C"], 5)
    
    # A connections
    add_edge!(g, node_map["A"], node_map["G1"], 10)
    add_edge!(g, node_map["A"], node_map["E"], 7)
    
    # B connections
    add_edge!(g, node_map["B"], node_map["C"], 2)
    add_edge!(g, node_map["B"], node_map["F"], 2)
    
    # C connections
    add_edge!(g, node_map["C"], node_map["G3"], 11)
    
    # D connections
    add_edge!(g, node_map["D"], node_map["S"], 6)
    add_edge!(g, node_map["D"], node_map["G2"], 5)
    
    # E connections
    add_edge!(g, node_map["E"], node_map["G1"], 2)
    
    # F connections
    add_edge!(g, node_map["F"], node_map["D"], 1)
    
    # G3 connections
    add_edge!(g, node_map["G3"], node_map["F"], 1)

    return g, node_map, heuristics
end
