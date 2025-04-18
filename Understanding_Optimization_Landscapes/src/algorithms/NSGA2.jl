include("../fitness_function.jl")
include("../plotter.jl")
include("_initialization.jl")
include("_selection.jl")
include("_crossover.jl")
include("_mutation.jl")
include("_distance.jl")


function NSGA2(lookup_table, N_FEATURES, POPULATION_SIZE, N_ITERATIONS, MUTATION_RATE, global_optimum)
    mean_fitness = Float64[]
    minimum_fitness = Float64[]
    humming_distance = Float64[]
    survivors_per_iteration = []
    n_iteration_required_to_best_fiteness = +Inf

    population = initialize_random_population(POPULATION_SIZE, N_FEATURES)
    fitness, accuracy = calculate_population_fitness(population, lookup_table)
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
        fitness, accuracy = calculate_population_fitness(population, lookup_table)
        if minimum(fitness) < best_fitness
            best_individual = population[argmin(fitness), :]
            best_fitness = minimum(fitness)
        end
        # SURVIVOR SELECTION
        n_feature_used = vec(sum(population, dims=2))
        population, accuracy, fitness, n_feature_used = nsga_selection(population, accuracy, fitness, n_feature_used, POPULATION_SIZE)
        
        push!(survivors_per_iteration, (fitness, n_feature_used))
        push!(mean_fitness, mean(fitness))
        push!(minimum_fitness, minimum(fitness))
        push!(humming_distance, average_hamming_distance(population))
        if global_optimum == best_fitness && n_iteration_required_to_best_fiteness==+Inf
            n_iteration_required_to_best_fiteness = i
        end
    end
    plot_humming_distance_evolution(humming_distance, "NSGA-II")
    plot_pareto_evolution(survivors_per_iteration)
    plot_fitness_evolution(mean_fitness, minimum_fitness, "NSGA-II")
    return best_fitness, best_individual, n_iteration_required_to_best_fiteness
end