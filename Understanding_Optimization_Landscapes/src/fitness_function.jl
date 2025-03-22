using DecisionTree, Base.Threads

function features_to_index(features_used::Vector{Int})
    idx = 1 # in julia gli array partono da indice 1
    for (i, bit) in enumerate(features_used)
        idx += bit * 2^(i-1)
    end
    return idx
end

function random_forest(features_used, X, y)
    X = X[:, features_used .== 1]  # Seleziona le colonne per cui feature_used è 1
    Random.seed!(42) # Divisione del dataset in training (80%) e test (20%)
    train_idx = randperm(size(X, 1))[1:round(Int, 0.8 * size(X, 1))]
    test_idx = setdiff(1:size(X, 1), train_idx)
    X_train, X_test = X[train_idx, :], X[test_idx, :]
    y_train, y_test = y[train_idx], y[test_idx]

    # Creazione e addestramento del modello
    model = RandomForestClassifier(n_trees=100, max_depth=10, min_samples_split=10)
    fit!(model, X_train, y_train)
    if all(x -> x == 0, X)
        println("Il vettore X è composto solo da zeri")
    end
    y_pred = predict(model, X_test)
    accuracy = mean(y_pred .== y_test)
    return accuracy
end

function penalty_number_of_features_used(features_used)
    return 0
end

function fitness_function(X, y, features_used, lookup_table)
    lookup_table_index_features_used = features_to_index(features_used)
    if lookup_table[lookup_table_index_features_used] != -1.0
        accuracy = lookup_table[lookup_table_index_features_used]
        println("Accuratezza da lookup_table: ", accuracy)
    else
        accuracy = random_forest(features_used, X, y)
        println("Accuratezza del modello Random Forest: ", accuracy)
        lookup_table[lookup_table_index_features_used] = accuracy 
    end
    penalty_weight = 0.1
    return accuracy + penalty_weight * penalty_number_of_features_used(features_used)
end

function calculate_population_fitness(X, y, population, lookup_table)
    println("POP: ", typeof(population), " ", size(population), size(population)[1])
    POPULATION_SIZE = size(population)[1]
    fitness = zeros(POPULATION_SIZE)
    @threads for i in 1:POPULATION_SIZE -1
        #println("Thread ", threadid(), " is processing individual ", i)
        fitness[i] = fitness_function(X, y, population[i,:], lookup_table)
    end
    return fitness
end