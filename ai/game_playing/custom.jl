function create_custom_graph()
    nodes = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", 
	"L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y"
    ]

    node_map = Dict(name => i for (i, name) in enumerate(nodes))
    reverse_node_map = Dict(i => name for (i, name) in enumerate(nodes))
    n_nodes = length(nodes)
    g = SimpleDiGraph(n_nodes)

    edges = [
	("A", "B"), ("A", "C"), ("A", "D"),
	("B", "E"), ("B", "F"), ("B", "G"),
	("C", "H"), ("C", "I"),
	("D", "J"), ("D", "K"),
	("E", "L"), ("E", "M"),
	("F", "N"), ("F", "O"),
	("G", "P"), ("G", "Q"),
	("H", "R"), ("H", "S"),
	("I", "T"), ("I", "U"),
	("J", "V"), ("J", "W"),
	("K", "X"), ("K", "Y")
    ]

    for (parent, child) in edges
        add_edge!(g, node_map[parent], node_map[child])
    end
    return g,node_map,reverse_node_map
end

function assign_custom_leaf_nodes(g,id_to_state)
    leaf_values = Dict(
	12 => 1,  13 => 3,  # L, M
	14 => 10, 15 => 7,  # N, O
	16 => 15, 17 => 9,  # P, Q
	18 => 1,  19 => 2,  # R, S
	20 => 20, 21 => 8,  # T, U
	22 => 7,  23 => 5,  # V, W
	24 => 9,  25 => 8   # X, Y
    )

    return leaf_values
end

function create_custom_graph_flipped()
    nodes = [
	"A",
	"D","C","B",
	"K","J","I","H","G","F","E",
	"Y","X","W","V","U","T","S","R","Q","P","O","N","M","L"
    ]

    node_map = Dict(name => i for (i, name) in enumerate(nodes))
    reverse_node_map = Dict(i => name for (i, name) in enumerate(nodes))
    n_nodes = length(nodes)
    g = SimpleDiGraph(n_nodes)

    # We flip the order of children in this list
    edges = [
        # Root A now points D -> C -> B
        ("A", "D"), ("A", "C"), ("A", "B"),
        
        # D points K -> J
        ("D", "K"), ("D", "J"),
        # C points I -> H
        ("C", "I"), ("C", "H"),
        # B points G -> F -> E
        ("B", "G"), ("B", "F"), ("B", "E"),

        # Level 3 to Leaves (Flipped pairs)
        ("K", "Y"), ("K", "X"),
        ("J", "W"), ("J", "V"),
        ("I", "U"), ("I", "T"),
        ("H", "S"), ("H", "R"),
        ("G", "Q"), ("G", "P"),
        ("F", "O"), ("F", "N"),
        ("E", "M"), ("E", "L")
    ]

    for (parent, child) in edges
        add_edge!(g, node_map[parent], node_map[child])
    end
    
    return g, node_map, reverse_node_map
end
function assign_custom_leaf_nodes_flipped(g,id_to_state)
    leaf_values = Dict(
	12=>8,
	13=>9,
	14=>5,
	15=>7,
	16=>8,
	17=>20,
	18=>2,
	19=>1,
	20=>9,
	21=>15,
	22=>7,
	23=>10,
	24=>3,
	25=>1,
    )

    return leaf_values
end
