using Graphs
using SimpleWeightedGraphs

function create_graph()
    # Original list
    full_names = [
        "Arad", "Zerind", "Oradea", "Sibiu", "Timisoara", "Lugoj", 
        "Mehadia", "Dobreta", "Craiova", "Rimnicu Vilcea", "Fagaras", 
        "Pitesti", "Bucharest", "Giurgiu", "Urziceni", "Hirsova", 
        "Eforie", "Vaslui", "Iasi", "Neamt"
    ]

    city_north_south_ranks = Dict(
	"Neamt"          => 2,
	"Oradea"         => 1,
	"Iasi"           => 4,
	"Zerind"         => 3,
	"Arad"           => 5,
	"Sibiu"          => 6,
	"Vaslui"         => 8,
	"Fagaras"        => 7,
	"Rimnicu Vilcea" => 9,
	"Timisoara"      => 10,
	"Urziceni"       => 13,
	"Hirsova"        => 14,
	"Lugoj"          => 11,
	"Pitesti"        => 12,
	"Bucharest"      => 16,
	"Mehadia"        => 15,
	"Craiova"        => 18,
	"Dobreta"        => 17,
	"Eforie"         => 19,
	"Giurgiu"        => 20
    )

    # 1. Sort alphabetically and take the first letter
    sorted_cities = sort(full_names,by = city -> city_north_south_ranks[city])
    
    # 2. Create the index using only the first letter
    # This creates a Dict like {"A" => 1, "B" => 2, ...}
    city_idx = Dict(string(name[1]) => i for (i, name) in enumerate(sorted_cities))
    num_cities = length(sorted_cities)

    g = SimpleWeightedGraph(num_cities)

    # Helper function using the single letter keys
    function add_city_edge!(graph, c1, c2, weight)
        add_edge!(graph, city_idx[c1], city_idx[c2], weight)
    end

    # 3. Add edges using the first letter of each city
    add_city_edge!(g, "A", "Z", 120)
    add_city_edge!(g, "Z", "O", 114)
    add_city_edge!(g, "A", "S", 225)
    add_city_edge!(g, "A", "T", 190)
    add_city_edge!(g, "O", "S", 243)
    add_city_edge!(g, "T", "L", 178)
    add_city_edge!(g, "L", "M", 112)
    add_city_edge!(g, "M", "D", 121)
    add_city_edge!(g, "D", "C", 193)
    add_city_edge!(g, "S", "F", 159)
    add_city_edge!(g, "S", "R", 129)
    add_city_edge!(g, "R", "C", 235)
    add_city_edge!(g, "R", "P", 156)
    add_city_edge!(g, "C", "P", 222)
    add_city_edge!(g, "F", "B", 340)
    add_city_edge!(g, "P", "B", 162)
    add_city_edge!(g, "B", "G", 115)
    add_city_edge!(g, "B", "U", 137)
    add_city_edge!(g, "U", "H", 158)
    add_city_edge!(g, "H", "E", 138)
    add_city_edge!(g, "U", "V", 229)
    add_city_edge!(g, "V", "I", 148)
    add_city_edge!(g, "I", "N", 140)

    return g, city_idx
end
