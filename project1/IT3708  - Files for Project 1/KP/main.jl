using CSV
using DataFrames
using Plots
using Statistics

include("initialization.jl")
include("fitness_function.jl")
include("selection.jl")
include("crossover.jl")
include("mutation.jl")
include("plots.jl")
include("distance.jl")

# Carica i dati dal file CSV
data = CSV.read("IT3708  - Files for Project 1/KP/knapPI_12_500_1000_82.csv", DataFrame)
# Extract columns: item ID, profit, and weight
item_ids = data[:, 1]   # Item identifiers
profits = data[:, 2]    # Profit values
weights = data[:, 3]    # Weight values

# Constants
N_POP = 1_000           # Population size
N_ITEMS = 500           # Number of items
MAX_CAPACITY = 280_785  # Maximum knapsack capacity
PROB_MUTATION = 0.8     # Probability of mutation
GENES_MUTATED = 2       # Number of genes mutated per individual

# Vectors to store fitness values over generations
global mean_fitness = Float64[]
global max_fitness = Float64[]
global min_fitness = Float64[]
global distance = Float64[]

# Initialize population
global curr_pop = initialize_population(N_POP, N_ITEMS);
global best_fitness = 0
global best_solution = zeros(Bool, N_ITEMS)
println("Starting Genetic Algorithm")
# Main Genetic Algorithm loop
for indice=1:50
    global curr_pop
    global best_solution
    global best_fitness
    # Evaluate population
    fitness, total_weight = evaluate_population(curr_pop, profits, weights, MAX_CAPACITY)
    if best_fitness < maximum(fitness)
        best_fitness = maximum(fitness)
        best_solution = curr_pop[argmax(fitness), :]
    end

    # Select parents for crossover using tournament selection
    crossovering_parents = tournament_selection(fitness, 400, 10)
    # Perform two-point crossover
    offspring = two_point_crossover(curr_pop[crossovering_parents, :])
    # Add offspring to the population
    curr_pop = vcat(curr_pop, offspring)
    # Apply mutation
    mutation_max_n_genes!(curr_pop, PROB_MUTATION, GENES_MUTATED)
    # Survival selection
    fitness, total_weight = evaluate_population(curr_pop, profits, weights, MAX_CAPACITY)
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
println("Fitness of the best individual: ", sum(best_solution .* profits))
println("Weight of the best individual: ", sum(best_solution .* weights), "/", MAX_CAPACITY)
