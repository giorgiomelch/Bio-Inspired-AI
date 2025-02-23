include("structs.jl")
include("parser.jl")
include("genetic_algorithm.jl")
include("initialization.jl")
include("fitness_function.jl")
include("selection.jl")
include("crossover.jl")
include("mutation.jl")
include("../plotter/plots.jl")
include("debug_time.jl")
using Statistics
###############
#   COSTANTS  #
###############
# TERMINATION CRITERION
N_ITER = 5_00
# POP CONSTANTS
N_POP = 1_000
POP_REPLACEMENT = 0.8
# TORUNAMENT SELECTION CONSTANTS
TOURNAMENT_SIZE = 20
# CROSSOVER CONSTANTS
# MUTATION COSTANTS
N_GEN_SWAP_MUTATION = 2
N_GEN_INVERSION = 2
N_GEN_SHIFT = 2

data_train_nbr = 1

HCP = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/Home_Care_Problem/data/train_"* string(data_train_nbr) *".json")

# debug()

@time best_individual = genetic_algorithm(HCP, N_POP, POP_REPLACEMENT, 
        N_ITER,
        TOURNAMENT_SIZE,
        N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT)

print_individual_routes(best_individual)
println("Best fitness: ", best_individual.fitness, ", feasible: ", best_individual.feasible, "\nBenchmark: ", HCP.benchmark)