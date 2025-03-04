include("structs.jl")
include("parser.jl")
include("genetic_algorithm.jl")
include("initialization.jl")
include("fitness_function.jl")
include("selection.jl")
include("crossover.jl")
include("mutation.jl")
include("../plotter/plots.jl")
include("../solutions/save_solution.jl")
using Statistics
###############
#   COSTANTS  #
###############
# TERMINATION CRITERION
N_ITER = 10_000
# POP CONSTANTS
N_POP = 500
# TORUNAMENT SELECTION CONSTANTS
TOURNAMENT_SIZE = 5
# CROSSOVER CONSTANTS
# MUTATION COSTANTS
N_GEN_SWAP_MUTATION = 4
N_GEN_INVERSION = 1
N_GEN_SHIFT = 2
PERC_SPLIT_MUTATION = 0.05

data_train_nbr = 0
for data_train_nbr in 0:0
        HCP = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/Home_Care_Problem/data/train_"* string(data_train_nbr) *".json")

        @time best_individual = genetic_algorithm(HCP, N_POP, 
                N_ITER,
                TOURNAMENT_SIZE,
                N_GEN_SWAP_MUTATION, N_GEN_INVERSION, N_GEN_SHIFT, PERC_SPLIT_MUTATION)

        print_individual_routes(best_individual)
        println("Best fitness: ", best_individual.fitness, ", feasible: ", best_individual.feasible, "\nis_back_before_return_time: ", all(r -> r.is_back_before_return_time, best_individual.routes), "\ncapacity_respected: ", all(r -> r.capacity_respected, best_individual.routes), "\ntime_windows_respected: ", all(r -> r.time_windows_respected, best_individual.routes))

        println("\nBenchmark: ", HCP.benchmark)
        save_individual_routes(best_individual, "./solution_"*string(data_train_nbr)*".txt", "/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/Home_Care_Problem/solutions")
        # aumentare il numero di crossover se nelle ultime x iyterazioni non c'è stato miglioramento
end