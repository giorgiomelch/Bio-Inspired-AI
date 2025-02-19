include("structs.jl")
include("parser.jl")
include("initialization.jl")
include("fitness_function.jl")
include("mutation.jl")
include("selection.jl")
include("../plotter/plots.jl")
include("debug_time.jl")
using Statistics

#COSTANTS
N_POP = 1_000
POP_REPLACEMENT = 0.5
# COSTANTS FOR MUTATION
N_GEN_SWAP_MUTATION = 1
N_GEN_INVERSION = 1

function genetic_algorithm(
    problem::HomeCareRoutingProblem, N_POP::Int, POP_REPLACEMENT::Float64, 
    N_GEN_SWAP_MUTATION::Int64, N_GEN_INVERSION::Int64)

    population = knn_initialize_population(problem, N_POP)
    update_population_fitness!(population, problem)
    for _ in 1:50 # TO DO - termination criterion - TO DO
        #SELZIONE GENITORI PER CROSSOVER
        indi = tournament_selection(population, Int(N_POP*POP_REPLACEMENT), 10)
        # TO DO - CROSSOVER - TO DO
        # crossover!(indi)
        # aggiungi i figli alla popolazione
        #MUTAZIONE
        apply_mutation!(population, N_GEN_SWAP_MUTATION, N_GEN_INVERSION)
        update_population_fitness!(population, problem)
        #SELEZIONE SURVIVORS
        elitism!(population)
        
        # MAPPA I PROGRESSI
        push_mean_fitness!(population)
        push_min_fitness!(population)
    end
    plot_routes2(problem.depot, population.best_individual.routes)
    plot_fitness_evolution(population)

end


HCP = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_1.json")

# debug()

genetic_algorithm(HCP, N_POP, POP_REPLACEMENT, N_GEN_SWAP_MUTATION, N_GEN_INVERSION)