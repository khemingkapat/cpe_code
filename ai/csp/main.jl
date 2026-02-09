using Plots,GraphRecipes,Graphs
include("box.jl")
include("sudoku.jl")


# g = create_adjacency_graph()
# assign = forward_checking(g, ["G", "S", "B"])
# println(check_adjacency_assignment(g,assign))
# assign = backtracking_search(g,["G","S","B"])
# println(check_adjacency_assignment(g,assign))
#
g = create_sudoku()
pre_assign = Dict{Int, Union{String, Nothing}}(n => nothing for n in 1:16)

pre_assign[3]  = "2"  # Row 1, Col 3
pre_assign[6]  = "4"  # Row 2, Col 2
pre_assign[11] = "4"  # Row 3, Col 3
pre_assign[14] = "3"  # Row 4, Col 2
assign = forward_checking(g,["1","2","3","4"],pre_assign)
println(assign)
