function initialize_node_domains(node_map, names, attr_domains)
    # Initialize dictionary with Set{String}
    node_domains = Dict{Int, Set{String}}()
    num_kids = length(names)
    
    for ((kid_idx, attr_idx), node_id) in node_map
        node_domains[node_id] = Set(attr_domains[attr_idx])
    end

    get_kid(name) = findfirst(==(name), names)
    
    last_n_attr, fav_attr, hated_attr, snack_attr = 1, 2, 3, 4

    # [cite_start]Clue 1: Julia chose candy[cite: 150]. [cite_start]Mary no apple[cite: 150].
    julia_idx = get_kid("Julia")
    node_domains[node_map[(julia_idx, snack_attr)]] = Set(["Candy"])
    
    mary_idx = get_kid("Mary")
    delete!(node_domains[node_map[(mary_idx, snack_attr)]], "Apple")

    # [cite_start]Clue 2: Alan is Small[cite: 151]. [cite_start]Alan's favorite not seal[cite: 151]. 
    # [cite_start]Beth no doughnut[cite: 151].
    alan_idx = get_kid("Alan")
    node_domains[node_map[(alan_idx, last_n_attr)]] = Set(["Small"])
    for i in 1:num_kids
        if i != alan_idx
            delete!(node_domains[node_map[(i, last_n_attr)]], "Small")
        end
    end
    delete!(node_domains[node_map[(alan_idx, fav_attr)]], "Seal")
    
    beth_idx = get_kid("Beth")
    delete!(node_domains[node_map[(beth_idx, snack_attr)]], "Doughnut")

    # [cite_start]Clue 3: No boys (Alan, Tom) chose doughnut[cite: 152].
    tom_idx = get_kid("Tom")
    for b_idx in [alan_idx, tom_idx]
        delete!(node_domains[node_map[(b_idx, snack_attr)]], "Doughnut")
    end
    # [cite_start]Clue 3 also implies one boy liked monkey[cite: 152]. 
    # Girls no corn-chip (per your logic).
    for g_idx in [julia_idx, mary_idx, beth_idx]
        delete!(node_domains[node_map[(g_idx, snack_attr)]], "Corn-chip")
    end

    # [cite_start]Clue 4: Beth liked seal[cite: 154]. [cite_start]Mary's last name was not Cook[cite: 154].
    node_domains[node_map[(beth_idx, fav_attr)]] = Set(["Seal"])
    delete!(node_domains[node_map[(mary_idx, last_n_attr)]], "Cook")

    # [cite_start]Clue 5: Tom not Brown[cite: 155]. [cite_start]Tom no apple[cite: 155].
    # [cite_start]Kid with last name Macgreger chose doughnut[cite: 156].
    delete!(node_domains[node_map[(tom_idx, last_n_attr)]], "Brown")
    delete!(node_domains[node_map[(tom_idx, snack_attr)]], "Apple")

    # [cite_start]Clue 6: Alan hated not giraffe[cite: 158, 192].
    # [cite_start]Cook liked monkey[cite: 157, 191].
    delete!(node_domains[node_map[(alan_idx, hated_attr)]], "Giraffe")

    return node_domains
end
