using CSV
using DataFrames
using Plots
using Statistics

include("initialization.jl")
include("fitness_function.jl")
include("selection.jl")
include("crossover.jl")
include("mutation.jl")
include("../plotter/plots.jl")
include("distance.jl")


# Constants
N_POP = 5               # Population size
N_ITEMS = 15            # Number of items
PROB_MUTATION = 0.8     # Probability of mutation
GENES_MUTATED = 2       # Number of genes mutated per individual

# Vectors to store fitness values over generations
global mean_fitness = Float64[]
global max_fitness = Float64[]
global min_fitness = Float64[]
global distance = Float64[]

# Initialize population
global problem_instance = load_home_care_problem("../data/train_0.json")
global best_fitness = 0
global best_solution = zeros(Bool, N_ITEMS)
println("Starting Genetic Algorithm")
# Main Genetic Algorithm loop
for indice=1:50
    global problem_instance
    global best_solution
    global best_fitness
    # Evaluate population
    fitness = evaluate_population(curr_pop)
    if best_fitness < maximum(fitness)
        best_fitness = maximum(fitness)
        best_solution = curr_pop[argmax(fitness), :]
    end
    println("Generation: ", indice, " Best fitness: ", best_fitness)
    # Select parents for crossover using tournament selection
    crossovering_parents = tournament_selection(fitness, Int64(round(N_POP/10*8)), 2)
    # Perform two-point crossover
    offspring = two_point_crossover(curr_pop[crossovering_parents, :])
    # Add offspring to the population
    curr_pop = vcat(curr_pop, offspring)
    # Apply mutation
    mutation_max_n_genes!(curr_pop, PROB_MUTATION, GENES_MUTATED)
    # Survival selection
    fitness = evaluate_population(curr_pop)
    best_candidates_indices = elitism(fitness, N_POP)
    # update curr_pop
    curr_pop = curr_pop[best_candidates_indices, :]
    # update fitness history
    push!(mean_fitness, mean(fitness))
    push!(max_fitness, maximum(fitness))
    push!(min_fitness, minimum(fitness))
    push!(distance, mean_hamming_distance(curr_pop))
end
# Plot fitness evolution and population diversity
plot_fitness_evolution(mean_fitness, max_fitness, min_fitness)
plot_humming_distance(distance)

# Print the fitness and weight of the best individual
println("Fitness of the best individual: ", best_solution)
println("Fitness of the best individual: ", evaluate_population(reshape(best_solution, 1, :)))
