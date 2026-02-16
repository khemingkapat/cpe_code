using Graphs, SimpleWeightedGraphs
using DataStructures # Required for PriorityQueue

function uniform_cost(graph, mapping, start_node, end_node)
    start_idx = mapping[start_node]
    end_idx = mapping[end_node]

    if start_idx == end_idx
        return true, [start_node]
    end

    reverse_mapping = Dict(v => k for (k, v) in mapping)
    
    pq = PriorityQueue{Int,Int}()
    pq[start_idx] = 0
    
    costs = Dict(idx => typemax(Int) for idx in values(mapping))
    costs[start_idx] = 0
    
    visited = Dict(idx => false for idx in values(mapping))
    parent = Dict{Int,Int}()

    while !isempty(pq)
        current_node, current_total_cost = dequeue_pair!(pq)

        if visited[current_node]
            continue
        end
        visited[current_node] = true

        if current_node == end_idx
            path = []
            curr = end_idx
            while curr != start_idx
                pushfirst!(path, reverse_mapping[curr])
                curr = parent[curr]
            end
            pushfirst!(path, reverse_mapping[start_idx])
            return true, path
        end

        for neighbor in neighbors(graph, current_node)
            if visited[neighbor]
                continue
            end

            edge_weight = Int(get_weight(graph, current_node, neighbor))
            new_path_cost = current_total_cost + edge_weight

            if new_path_cost < costs[neighbor]
                costs[neighbor] = new_path_cost
                parent[neighbor] = current_node
                pq[neighbor] = new_path_cost
            end
        end
    end

    return false, []
end
