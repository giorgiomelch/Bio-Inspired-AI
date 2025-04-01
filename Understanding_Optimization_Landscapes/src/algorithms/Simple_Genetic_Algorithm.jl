include("../fitness_function.jl")
include("../plotter.jl")
include("_distance.jl")
include("_initialization.jl")
include("_selection.jl")
include("_crossover.jl")
include("_mutation.jl")

function simple_genetic_algorithm(lookup_table, N_FEATURES, POPULATION_SIZE, N_ITERATIONS, MUTATION_RATE, global_optimum)
    mean_fitness = Float64[]
    minimum_fitness = Float64[]
    humming_distance = Float64[]
    n_iteration_required_to_best_fiteness = +Inf
    population = initialize_random_population(POPULATION_SIZE, N_FEATURES)
    fitness, accuracy = calculate_population_fitness(population, lookup_table)
    best_individual = population[argmin(fitness), :]
    best_fitness = minimum(fitness)
    for i in 1:N_ITERATIONS
        #println("ITERATION N: ", i, " mean fitness: ", round(mean(fitness), digits=5), " minimum fitness: ", round(minimum(fitness), digits=3))
        # PARENT SELECTION FOR CROSSOVER
        parents = tournament_selection(population, fitness, POPULATION_SIZE, 3)
        # CROSSOVER
        offsprings = two_point_crossover(parents)
        # MUTATION
        mutation_bit_flip!(offsprings, MUTATION_RATE)
        population = offsprings
        # EVALUATE FITNESS
        fitness, accuracy = calculate_population_fitness(population, lookup_table)
        if minimum(fitness) < best_fitness
            best_individual = population[argmin(fitness), :]
            best_fitness = minimum(fitness)
        end
        # SURVIVOR SELECTION
        push!(mean_fitness, mean(fitness))
        push!(minimum_fitness, minimum(fitness))
        push!(humming_distance, average_hamming_distance(population))
        if global_optimum == best_fitness && n_iteration_required_to_best_fiteness==+Inf
            n_iteration_required_to_best_fiteness = i
        end
    end
    plot_humming_distance_evolution(humming_distance)
    plot_fitness_evolution(mean_fitness, minimum_fitness)
    return best_fitness, best_individual, n_iteration_required_to_best_fiteness
end