include("structs.jl")
include("parser.jl")
include("initialization.jl")
include("fitness_function.jl")
include("mutation.jl")
include("selection.jl")


#COSTANTS
N_POP = 1_000
N_GEN_SWAP_MUTATION = 1
POP_REPLACEMENT = 0.5


# GENETIC ALGORITHM
a = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_1.json")
pop = initialize_pop_random(a, N_POP)
update_population_fitness!(pop, a)
println("\n", pop.best_individual.fitness)
apply_mutation!(pop, N_GEN_SWAP_MUTATION)
update_population_fitness!(pop, a)
println("\n", pop.best_individual.fitness)

println("\n", length(pop.individuals))
append!(pop.individuals, pop.individuals)
println("\n", length(pop.individuals))

elitism!(pop)
println("\n", length(pop.individuals))

indi = tournament_selection(pop, 250, 10)
println("\n", length(indi))





function genetic_algorithm(problem::HomeCareRoutingProblem, N_POP::Int, N_GEN_SWAP_MUTATION::Int)
    population = initialize_pop_random(problem, N_POP)
    update_population_fitness!(population, problem)
    for _ in 1:50 # TO DO - termination criterion - TO DO
        #SELZIONE GENITORI PER CROSSOVER
        indi = tournament_selection(pop, 250, 10)
        # TO DO - CROSSOVER - TO DO
        # crossover!(indi)
        # aggiungi i figli alla popolazione
        #MUTAZIONE
        apply_mutation!(population, N_GEN_SWAP_MUTATION)
        update_population_fitness!(population, problem)
        #SELEZIONE SURVIVORS
        elitism!(population)
        
        # TO DO - MAPPA I PROGRESSI - TO DO
    end
end