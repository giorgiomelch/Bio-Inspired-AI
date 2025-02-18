include("structs.jl")
include("parser.jl")
include("initialization.jl")
include("fitness_function.jl")
include("mutation.jl")


#COSTANTS
N_POP = 1_000
N_GEN_SWAP_MUTATION = 1
POP_REPLACEMENT = 0.5


# GENETIC ALGORITHM
a = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_1.json")
b = initialize_pop_random(a, N_POP)
update_population_fitness!(b, a)
println("\n", b.best_individual.fitness)
apply_mutation!(b, N_GEN_SWAP_MUTATION)
update_population_fitness!(b, a)
println("\n", b.best_individual.fitness)








function genetic_algorithm(problem::HomeCareRoutingProblem, N_POP::Int, N_GEN_MUTATION::Int, POP_REPLACEMENT::Float64)
    population = initialize_pop_random(problem, N_POP)
    calculate_fitness!(population, problem)
    for _ in 1:50 #termination criterion TO DO
        #CROSSOVER TO DO
        #MUTZIONE
        apply_mutation!(population, N_GEN_SWAP_MUTATION)
        #SELEZIONE SURVIVORS TO DO
        
        #MAPPA I PROGRESSI
    end
end