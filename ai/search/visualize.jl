function prepare_graph(state_space,node_map)
    rev_node_map = Dict(v=>k for (k,v) in node_map)

    active_nodes = [v for v in vertices(state_space) if degree(state_space, v) > 0]
    sg, vmap = induced_subgraph(state_space, active_nodes)

    sg_rev_node_map = Dict(v => rev_node_map[vmap[v]] for v in 1:nv(sg))
    sg_labels = [string(sg_rev_node_map[i]) for i in 1:nv(sg)]

    sg_edge_labels = Dict(
        (src(e), dst(e)) => "S($(Int(div(weight(e), 10))), $(Int(rem(weight(e), 10))))"
	for e in edges(sg)
    )
    return sg, sg_labels, sg_edge_labels, sg_rev_node_map
end

function plot_state_space(sg, labels, edge_labels, rev_node_map; root_state=(2, 2, 0))
    root_idx = findfirst(x -> rev_node_map[x] == root_state, 1:nv(sg))

    return graphplot(sg,
        names = labels,
        edgelabel = edge_labels,
        method = :layered,
        root = root_idx, # Use the dynamic index found above
        nodesize = 0.1,
        shorten = 0.0,
        fontsize = 6,
        linecolor = :gray,
        size = (1200, 1200),
        self_loop_size = 0.2
    )
end

function write_mermaid(graph,rev_node_map)
    println("graph TD")
    for node in vertices(graph)
	c,d,b = rev_node_map[node]
	println("\t$(c)$(d)$(b)[\"($(c), $(d), $(b))\"]")
    end


    for e in edges(graph)
	u, v = src(e), dst(e)

	w = Int(weight(e))

	c = div(w, 10)
	d = rem(w, 10)

	sc,sd,sb = rev_node_map[u]
	dc,dd,db = rev_node_map[v]

	println("\t$(sc)$(sd)$(sb)--->|\"S($(c),$(d))\"|$(dc)$(dd)$(db)")
    end
end
