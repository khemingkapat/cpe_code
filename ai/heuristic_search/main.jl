using DataStructures
include("create_map.jl")
include("best_first.jl")
include("a_star.jl")
include("hill_climbing.jl")
n = 8
goal = (2,3)
start = (6,6)
my_map = create_blank_map(n)

add_walls!(my_map, [(4,3),(4,4),(4,5),(4,6),(4,7),(5,2),(6,3),(6,7)])
add_manhattan!(my_map,(2,3))

g_map = create_blank_map(n)
add_manhattan!(g_map,(start))
my_map = my_map + g_map
display(my_map)

result,path = a_star(my_map,start,goal)
println("a_star_search => ",path)
