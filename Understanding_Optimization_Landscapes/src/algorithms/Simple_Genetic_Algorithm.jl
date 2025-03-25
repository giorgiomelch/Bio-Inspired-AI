include("../fitness_function.jl")
include("../plotter.jl")
include("_initialization.jl")
include("_selection.jl")
include("_crossover.jl")
include("_mutation.jl")

function simple_genetic_algorithm(lookup_table, N_FEATURES, POPULATION_SIZE, N_ITERATIONS, MUTATION_RATE)
    mean_fitness = Float64[]
    minimum_fitness = Float64[]
    population = initialize_random_population(POPULATION_SIZE, N_FEATURES)
    fitness, accuracy = calculate_population_fitness(population, lookup_table)
    best_individual = population[argmax(fitness), :]
    best_fitness = maximum(fitness)
    for i in 1:N_ITERATIONS
        if i % 10 == 0 && i != 0
            println("ITERATION N: ", i, " mean fitness: ", round(mean(fitness), digits=3), " minimum fitness: ", round(minimum(fitness), digits=3))
        end
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
        population, fitness = elitism(population, fitness, POPULATION_SIZE)
        push!(mean_fitness, mean(fitness))
        push!(minimum_fitness, minimum(fitness))
    end
    plot_fitness_evolution(mean_fitness, minimum_fitness)
    return best_fitness, best_individual
end