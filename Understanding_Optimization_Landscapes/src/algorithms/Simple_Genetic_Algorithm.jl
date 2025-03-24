include("../fitness_function.jl")
include("../plotter.jl")
include("_initialization.jl")
include("_selection.jl")
include("_crossover.jl")
include("_mutation.jl")

function simple_genetic_algorithm(X, y, lookup_table, POPULATION_SIZE, N_ITERATIONS, MUTATION_RATE)
    mean_fitness = Float64[]
    max_fitness = Float64[]
    N_GENES = size(X, 2)
    population = initialize_random_population(POPULATION_SIZE, N_GENES)
    fitness = calculate_population_fitness(X, y, population, lookup_table)
    best_individual = population[argmax(fitness), :]
    best_fitness = maximum(fitness)
    for i in 1:N_ITERATIONS
        println("ITERATION N: ", i)
        # PARENT SELECTION FOR CROSSOVER
        parents = tournament_selection(population, fitness, POPULATION_SIZE, 3)
        # CROSSOVER
        offsprings = two_point_crossover(parents)
        # MUTATION
        mutation_bit_flip!(offsprings, MUTATION_RATE)
        population = vcat(population, offsprings)
        # EVALUATE FITNESS
        fitness = calculate_population_fitness(X, y, population, lookup_table)
        if maximum(fitness) > best_fitness
            best_individual = population[argmax(fitness), :]
            best_fitness = maximum(fitness)
        end
        # SURVIVOR SELECTION
        population, fitness = elitism(population, fitness, POPULATION_SIZE)
        push!(mean_fitness, mean(fitness))
        push!(max_fitness, maximum(fitness))
    end
    plot_fitness_evolution(mean_fitness, max_fitness)
    return best_individual, best_fitness
end