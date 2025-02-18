include("structs.jl")
include("parser.jl")
include("initialization.jl")
include("fitness_function.jl")


#COSTANTS
N_POP = 1_000
N_GEN_MUTATION = 1


# GENETIC ALGORITHM
a = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/project2/data/train_1.json")
b = initialize_pop_random(a, N_POP)
println(b.individuals[1].fitness)
calculate_fitness!(b, a)
for i in b.individuals
    print(i.fitness," ")
end