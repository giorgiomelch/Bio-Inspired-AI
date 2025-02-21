include("structs.jl")
include("parser.jl")
include("initialization.jl")
include("fitness_function.jl")
include("mutation.jl")
include("selection.jl")
include("../plotter/plots.jl")
include("debug_time.jl")
include("genetic_algorithm.jl")
using Statistics
###############
#   COSTANTS  #
###############
# TERMINATION CRITERION
N_ITER = 500
# POP CONSTANTS
N_POP = 5_000
POP_REPLACEMENT = 0.5
# TORUNAMENT SELECTION CONSTANTS
TOURNAMENT_SIZE = 10
# CROSSOVER CONSTANTS
# MUTATION COSTANTS
N_GEN_SWAP_MUTATION = 1
N_GEN_INVERSION = 1
N_GEN_SHIFT = 1



HCP = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_0.json")

# debug()

@time genetic_algorithm(HCP, N_POP, POP_REPLACEMENT, 
    N_ITER,
    TOURNAMENT_SIZE,
    N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT)