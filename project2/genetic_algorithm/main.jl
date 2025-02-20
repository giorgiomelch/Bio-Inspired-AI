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

#COSTANTS
N_POP = 1_000
POP_REPLACEMENT = 0.5
# COSTANTS FOR MUTATION
N_GEN_SWAP_MUTATION = 2
N_GEN_INVERSION = 2



HCP = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_0.json")

# debug()

@time genetic_algorithm(HCP, N_POP, POP_REPLACEMENT, N_GEN_SWAP_MUTATION, N_GEN_INVERSION)