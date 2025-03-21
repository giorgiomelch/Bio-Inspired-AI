using CSV, DataFrames, Random, DecisionTree, Statistics
using Base.Threads

function random_forest(features_used, X, y)
    # Seleziona solo le colonne indicate da features_used
    X = X[:, features_used .== 1]  # Seleziona le colonne per cui feature_used è 1

    # Divisione del dataset in training (80%) e test (20%)
    Random.seed!(42)
    train_idx = randperm(size(X, 1))[1:round(Int, 0.8 * size(X, 1))]
    test_idx = setdiff(1:size(X, 1), train_idx)

    X_train, X_test = X[train_idx, :], X[test_idx, :]
    y_train, y_test = y[train_idx], y[test_idx]  # Conversione in numeri

    # Creazione e addestramento del modello
    model = RandomForestClassifier(n_trees=100, max_depth=10, min_samples_split=10)
    fit!(model, X_train, y_train)
    if all(x -> x == 0, X)
        println("Il vettore X è composto solo da zeri")
    end
    # Predizione sul test set
    y_pred = predict(model, X_test)
    # Calcolo dell'accuratezza
    accuracy = mean(y_pred .== y_test)
    println("Accuratezza del modello Random Forest: ", accuracy)
    return accuracy
end

function penalty_number_of_features_used(features_used)
    return 0
end

function fitness_function(X, y, features_used)
    penalty_weight = 0.1
    return random_forest(features_used, X, y) + penalty_weight * penalty_number_of_features_used(features_used)
end

function calculate_population_fitness(X, y, population)
    println("POP: ", typeof(population), " ", size(population), size(population)[1])
    POPULATION_SIZE = size(population)[1]
    fitness = zeros(POPULATION_SIZE)
    @threads for i in 1:POPULATION_SIZE -1
        #println("Thread ", threadid(), " is processing individual ", i)
        fitness[i] = fitness_function(X, y, population[i,:])
    end
    return fitness
end





function dacanc()
    data_path = joinpath(@__DIR__, "..", "data", "winequality-white.csv")

    # Caricamento del dataset
    df = CSV.read(data_path, DataFrame; header=true, delim=';')

    # Separazione delle features e delle label
    X = Matrix(select(df, Not(last(names(df)))))  # Tutte le colonne tranne l'ultima
    y = df[!, last(names(df))]  # L'ultima colonna

    # Creazione di un vettore binario features_used (ad esempio, usiamo tutte le features inizialmente)
    features_used = ones(Int, size(X, 2))  # Usa tutte le feature (tutte sono selezionate)

    # Chiamata alla funzione random_forest
    random_forest(features_used, X, y)
end