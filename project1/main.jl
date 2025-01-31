using CSV
using DataFrames
using Plots
using Statistics

include("initialization.jl")
include("fitness_function.jl")
include("selection.jl")
include("crossover.jl")
include("mutation.jl")
include("plot_fitness_evolution.jl")

# Carica i dati dal file CSV
data = CSV.read("./IT3708  - Files for Project 1/KP/knapPI_12_500_1000_82.csv", DataFrame)
# Dividi i dati in colonne: identificatore, profitto, peso
item_ids = data[:, 1]  # Identificatori
profits = data[:, 2]  # Profitti
weights = data[:, 3]  # Pesi

# Constants
N_POP = 1_000
N_ITEMS = 500
MAX_CAPACITY = 280_785
PROB_MUTATION= 0.8
GENES_MUTATED = 2

# Vettori per salvare i valori di fitness
global mean_fitness = Float64[]
global max_fitness = Float64[]
global min_fitness = Float64[]
# Initialize population
global curr_pop = initialize_population(N_POP, N_ITEMS);

for indice=1:50
    global curr_pop
    # Evaluate population
    fitness, total_weight = evaluate_population(curr_pop, profits, weights, MAX_CAPACITY)
    # Select indices of parents to crossover
    crossovering_parents = tournament_selection(fitness, 400, 10)
    # Crossover
    offspring = two_point_crossover(curr_pop[crossovering_parents, :])
    curr_pop = vcat(curr_pop, offspring)
    # Mutation
    mutation_max_n_genes!(curr_pop, PROB_MUTATION, GENES_MUTATED)
    # Replacement
    fitness, total_weight = evaluate_population(curr_pop, profits, weights, MAX_CAPACITY)
    best_candidates_indices = elitism(fitness, N_POP)
    # update curr_pop
    curr_pop = curr_pop[best_candidates_indices, :]

    push!(mean_fitness, mean(fitness))
    push!(max_fitness, maximum(fitness))
    push!(min_fitness, minimum(fitness))
end
plot_fitness_evolution(mean_fitness, max_fitness, min_fitness)

# Calcolare di nuovo il fitness per l'output finale
final_fitness, final_weight = evaluate_population(curr_pop, profits, weights, MAX_CAPACITY)

# Trova l'indice del miglior individuo (con fitness massimo)
best_index = argmax(final_fitness)
# Stampa il peso del miglior individuo
println("Fitness del miglior individuo: ", final_fitness[best_index])
println("Peso del miglior individuo: ", final_weight[best_index], "/", MAX_CAPACITY)
#println("Best solution: ", curr_pop[argmax(final_fitness), :])