include("data.jl")
include("instances.jl")

function calculate_class_score(df::DataFrame, observed_features::Dict, specific_class::String)
    total_rows = nrow(df)
    
    class_df = filter(row -> row[end] == specific_class, df)
    class_count = nrow(class_df)
    
    prior_prob = class_count / total_rows
    
    likelihood = 1.0
    for (feature_name, feature_value) in observed_features
        match_count = count(x -> x == feature_value, class_df[!, feature_name])
        
        prob_feature = match_count / class_count
        
        likelihood = likelihood * prob_feature
    end
    
    return prior_prob * likelihood
end

function predict_naive_bayes(df::DataFrame, observed_features::Dict)
    classes = unique(df[!, end])
    
    best_class = ""
    highest_score = -1.0
    
    for c in classes
        score = calculate_class_score(df, observed_features, c)
        
        println("Score for $c: ", score)
        
        if score > highest_score
            highest_score = score
            best_class = c
        end
    end
    
    return best_class
end


println("Prediction 1: ", predict_naive_bayes(df, instance_1))
println("===================================================")
println("Prediction 2: ", predict_naive_bayes(df, instance_2))
println("===================================================")
println("Prediction 3: ", predict_naive_bayes(df, instance_3))
println("===================================================")
println("Prediction 4: ", predict_naive_bayes(df, instance_4))
println("===================================================")
println("Prediction 5: ", predict_naive_bayes(df, instance_5))
