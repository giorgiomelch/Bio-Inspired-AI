using DecisionTree, Base.Threads

function features_to_index(features_used::Vector{Int})
    index = 0
    for (i, bit) in enumerate(reverse(features_used))
        index += bit * 2^(i-1)
    end
    return index
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
        return -1.0
    end
    y_pred = DecisionTree.predict(model, X_test)
    accuracy = mean(y_pred .== y_test)
    return accuracy
end

function fitness_function(features_used, lookup_table)
    if all(x -> x == 0, features_used)
        return +1.0, 0.0
    end
    lookup_table_index = features_to_index(features_used)
    accuracy = lookup_table[lookup_table_index]
    error = 1 - accuracy
    penalty_weight = 0.05
    fitness = error + penalty_weight * sum(features_used)
    return fitness, accuracy
end

function calculate_population_fitness(population, lookup_table)
    POPULATION_SIZE = size(population)[1]
    fitness = zeros(POPULATION_SIZE)
    accuracy = zeros(POPULATION_SIZE)
    for i in 1:POPULATION_SIZE
        fitness[i], accuracy[i] = fitness_function(population[i,:], lookup_table)
    end
    return fitness, accuracy
end