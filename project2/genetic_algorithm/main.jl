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
N_GEN_SWAP_MUTATION = 1
POP_REPLACEMENT = 0.5

function genetic_algorithm(
    problem::HomeCareRoutingProblem, N_POP::Int, POP_REPLACEMENT::Float64, N_GEN_SWAP_MUTATION::Int64)
    population = initialize_pop_random(problem, N_POP)
    update_population_fitness!(population, problem)
    for _ in 1:50 # TO DO - termination criterion - TO DO
        #SELZIONE GENITORI PER CROSSOVER
        indi = tournament_selection(pop, Int(N_POP*POP_REPLACEMENT), 10)
        # TO DO - CROSSOVER - TO DO
        # crossover!(indi)
        # aggiungi i figli alla popolazione
        #MUTAZIONE
        apply_mutation!(population, N_GEN_SWAP_MUTATION)
        update_population_fitness!(population, problem)
        #SELEZIONE SURVIVORS
        elitism!(population)
        
        # TO DO - MAPPA I PROGRESSI - TO DO
        push_mean_fitness!(population)
        push_min_fitness!(population)
    end
    plot_routes2(a.depot, population.best_individual.routes)
    plot_fitness_evolution(population)

end


HCP = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_1.json")

#debug()

genetic_algorithm(a, N_POP, POP_REPLACEMENT, N_GEN_SWAP_MUTATION)