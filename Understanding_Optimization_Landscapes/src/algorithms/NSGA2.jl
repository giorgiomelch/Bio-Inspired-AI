include("../fitness_function.jl")
include("../plotter.jl")
include("_initialization.jl")
include("_selection.jl")
include("_crossover.jl")
include("_mutation.jl")

function calculate_n_feature_used(population)
    number_of_individuals, _ = size(population)
    n_feature_used = zeros(Int64, number_of_individuals)
    for i in 1:number_of_individuals
        n_feature_used[i] = sum(population[i, :])
    end
    return n_feature_used
end

function NSGA2(X, y, lookup_table, POPULATION_SIZE, N_ITERATIONS, MUTATION_RATE)
    N_GENES = size(X, 2)
    population = initialize_random_population(POPULATION_SIZE, N_GENES)
    fitness = calculate_population_fitness(X, y, population, lookup_table)
    best_individual = population[argmax(fitness), :]
    best_fitness = maximum(fitness)
    for i in 1:N_ITERATIONS
        println(size(population))
        println("Iterazione: ", i, " - Fitness migliore: ", best_fitness)
        # PARENT SELECTION FOR CROSSOVER
        parents = tournament_selection(population, fitness, POPULATION_SIZE, 3)
        # CROSSOVER
        offsprings = two_point_crossover(parents)
        # MUTATION
        mutation_bit_flip!(offsprings, MUTATION_RATE)
        population = vcat(population, offsprings)
        # EVALUATE FITNESS
        accuracy = calculate_population_fitness(X, y, population, lookup_table)

        if maximum(accuracy) > best_fitness
            best_individual = population[argmax(accuracy), :]
            best_fitness = maximum(accuracy)
        end
        n_feature_used = calculate_n_feature_used(population)
        # SURVIVOR SELECTION
        plot_NSGA2_population(accuracy, n_feature_used)
        population, accuracy = nsga_selection(population, accuracy, n_feature_used, POPULATION_SIZE)
        plot_NSGA2_population(accuracy, n_feature_used)
    end
    return best_individual, best_fitness
end