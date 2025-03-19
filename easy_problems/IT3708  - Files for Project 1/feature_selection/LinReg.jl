using MLJ
using Random

"""
    get_population_fitness(model, X, y, population; rng=StableRNG(123))

Given a `model`, a dataset `X`, and a vector of targets `y`, compute the fitness for each individual in `population`.
Each individual is represented by a binary vector selecting features.

## Parameters:
- `model`: An MLJ model.
- `X`: An `n × m` matrix of features.
- `y`: A vector of length `n` with target values.
- `population`: A matrix of shape `(num_individuals, num_features)`, where each row is a binary vector representing an individual.
- `rng`: A StableRNGs random number generator for reproducibility.

## Returns:
- A vector of fitness scores (one per individual).
"""
function get_population_fitness(model, X, y, population; rng=Random.GLOBAL_RNG)
    fitness_scores = zeros(size(population, 1))  # Un vettore per le fitness

    for i in 1:size(population, 1)
        ind = population[i, :]  # Ottieni l'individuo i-esimo
        X_sub = get_columns(X, ind)  # Seleziona le feature corrispondenti
        fitness_scores[i] = get_fitness(model, X_sub, y; rng=rng)  # Calcola fitness
    end

    return fitness_scores
end

"""
    get_fitness(model, Xsub, y; rng=myRNG)


Given a `model`, a subset of the data `Xsub` and a vector of targets `y` , return the square root of the MSE of the model.

## Parameters
- `model`: An _MLJ_ model.
- `Xsub`: an ``n x m`` matrix of data that should be used for training the model.
- `y`: a vector of length ``n`` containing the regression (target) values of observations
- `rng`: a StableRNGs random number generator for reproducible results
"""
function get_fitness(model, Xsub, y; rng=Random.GLOBAL_RNG)
    # In MLJ, a _machine_ will retain the learnt parameters
    # This is why we need to create a new one every function call
    mach = machine(model, Xsub, y)
    # Do the split
    train, test = partition(eachindex(y), 0.8, rng=rng)
    # Train using the training rows
    fit!(mach, rows=train, verbosity=0);
    # calculate yhat
    yhat = predict(mach, Xsub[test, :])

    return rmse(yhat, y[test])
end

"""
    get_columns(X, ind)

Get columns of `X` given the bitstring `ind`.

## Parameters

- `X`: A ``n x m`` matrix containing the data that should be used for training the model
- `ind`: a binary vector of length `m` indicating which columns to keep
"""
function get_columns(X, ind)
    indices = [i for (i,j) in enumerate(ind) if j==1]
    return X[:, indices]
end
