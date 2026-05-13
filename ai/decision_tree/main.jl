include("data.jl")

# Improved function using proper keyword arguments
function calculate_information_gain(df; target_col=:MoveTheCar, by=nothing)
    n_rows = nrow(df)
    if n_rows == 0 return 0.0 end
    
    E0 = 0.0
    target_classes = unique(df[!, target_col])
    
    for class in target_classes
        class_amount = count(==(class), df[!, target_col])
        p = class_amount / n_rows
        E0 -= p * log2(p) # log2 is standard for entropy, log10 works but changes scale
    end
    
    if isnothing(by)
        return E0
    end
    
    classes = unique(df[!, by])
    IG = E0
    for class in classes
        subset_df = df[df[!, by] .== class, :]
        class_rows = nrow(subset_df)
	class_entropy = calculate_information_gain(subset_df, target_col=target_col)
	class_weight = (class_rows / n_rows)

        IG -= class_entropy * class_weight
    end
    return IG
end

function create_decision_tree(df::DataFrame; target_col=:MoveTheCar, depth=0)
    # 1. Guard Clause: If the target column has only one unique value, we are at a leaf
    unique_targets = unique(df[!, target_col])
    if length(unique_targets) <= 1
        println("  " ^ depth, "Leaf Node: ", unique_targets[1])
        return
    end

    max_ig = -Inf
    max_col = nothing
    
    for col in names(df, Not(target_col))
        col_ig = calculate_information_gain(df, target_col=target_col, by=col)
        if col_ig > max_ig
            max_ig = col_ig
            max_col = col
        end
    end

    if max_ig <= 0 || isnothing(max_col)
        println("  " ^ depth, "Stop Split (No Gain). Predicted: ", unique_targets[1])
        return
    end

    println("  " ^ depth, "Split on: ", max_col, " (IG: ", round(max_ig, digits=4), ")")

    classes = unique(df[!, max_col])
    
    for class in classes
        subset_df = df[df[!, max_col] .== class, :]
        
        println("  " ^ depth, "  Branch [", max_col, " == ", class, "]:")
        
        create_decision_tree(subset_df, target_col=target_col, depth=depth + 1)
    end
end

# To run it:
create_decision_tree(df, target_col=:MoveTheCar)
