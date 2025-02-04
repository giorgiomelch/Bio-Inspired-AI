using CSV
using DataFrames
using Plots
using Statistics
using MLJ
using StableRNGs

include("initialization.jl")
include("selection.jl")
include("crossover.jl")
include("mutation.jl")
include("plots.jl")
include("distance.jl")
include("LinReg.jl")

# Carica i dati dal file CSV
data = CSV.read("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project1/IT3708  - Files for Project 1/feature_selection/dataset.txt", DataFrame; header=0)
y, X = unpack(data, ==(:Column102));
 # ---------------------
myRNG = 123

# Constants
N_POP = 100
N_ITEMS = 101
MAX_RMSE = 0.124
PROB_MUTATION= 0.8
GENES_MUTATED = 4

# Vettori per salvare i valori di fitness
global mean_fitness = Float64[]
global max_fitness = Float64[]
global min_fitness = Float64[]
global distance = Float64[]

# Initialize population
global curr_pop = initialize_population(N_POP, N_ITEMS);
global best_rmse = Inf
global iter = 0   
global best_features_selection = []

LinearRegressor = @load LinearRegressor pkg=MLJLinearModels verbosity=0
model = LinearRegressor()

while best_rmse ≥ MAX_RMSE
    global iter += 1
    global curr_pop
    # Evaluate population
    fitness = get_population_fitness(model, X, y, curr_pop, rng=myRNG)
    best_rmse = minimum(fitness)  # Trova il miglior rmse della generazione

    println("Iteration n' $iter - Best RMSE: $best_rmse")  # Debug
    global best_rmse
    # if the best rmse is less than the threshold, break the loop
    if best_rmse < MAX_RMSE
        global best_features_selection = curr_pop[argmin(fitness), :]
        break
    end
    crossovering_parents = tournament_selection(fitness, Int64(round(N_POP/10*8)), 10)    # Select indices of parents to crossover
    offspring = two_point_crossover(curr_pop[crossovering_parents, :])  # Crossover
    curr_pop = vcat(curr_pop, offspring)

    mutation_max_n_genes!(curr_pop, PROB_MUTATION, GENES_MUTATED)    # Mutation

    fitness = get_population_fitness(model, X, y, curr_pop, rng=myRNG)
    best_candidates_indices = elitism(fitness, N_POP)   # Select indices for survival selection
    curr_pop = curr_pop[best_candidates_indices, :] # Survival selection

    # update fitness history
    push!(mean_fitness, mean(fitness))
    push!(max_fitness, maximum(fitness))
    push!(min_fitness, minimum(fitness))
    push!(distance, mean_hamming_distance(curr_pop))
end
plot_fitness_evolution(mean_fitness, max_fitness, min_fitness)
plot_humming_distance(distance)
# calculate fitness for final output
best_fitness = get_fitness(model, get_columns(X, best_features_selection), y, rng=myRNG)

println("Best RMSE: ", best_fitness)