include("../fitness_function.jl")
include("../plotter.jl")
include("_initialization.jl")
include("_selection.jl")
include("_crossover.jl")
include("_mutation.jl")

function calculate_n_feature_used(population)
    n_features = sum(population, dims=2)
    return vec(n_features)
end

function NSGA2(lookup_table, N_FEATURES, POPULATION_SIZE, N_ITERATIONS, MUTATION_RATE)
    mean_fitness = Float64[]
    minimum_fitness = Float64[]
    population = initialize_random_population(POPULATION_SIZE, N_FEATURES)
    fitness = calculate_population_fitness(population, lookup_table)
    best_individual = population[argmin(fitness), :]
    best_fitness = minimum(fitness)
    for i in 1:N_ITERATIONS
        # PARENT SELECTION FOR CROSSOVER
        parents = tournament_selection(population, fitness, POPULATION_SIZE, 2)
        # CROSSOVER
        offsprings = two_point_crossover(parents)
        # MUTATION
        mutation_bit_flip!(offsprings, MUTATION_RATE)
        population = vcat(population, offsprings)
        # EVALUATE FITNESS
        fitness = calculate_population_fitness(population, lookup_table)
        if minimum(fitness) < best_fitness
            best_individual = population[argmin(fitness), :]
            best_fitness = minimum(fitness)
        end
        n_feature_used = calculate_n_feature_used(population)
        # SURVIVOR SELECTION
        plot_NSGA2_population(fitness, n_feature_used)
        population, fitness = nsga_selection(population, fitness, n_feature_used, POPULATION_SIZE)
        n_feature_used = calculate_n_feature_used(population)
        plot_NSGA2_population(fitness, n_feature_used)
        push!(mean_fitness, mean(fitness))
        push!(minimum_fitness, minimum(fitness))
    end
    plot_fitness_evolution(mean_fitness, minimum_fitness)
    return best_individual, best_fitness
end