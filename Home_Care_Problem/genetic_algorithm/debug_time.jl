include("structs.jl")
include("parser.jl")
include("genetic_algorithm.jl")
include("initialization.jl")
include("fitness_function.jl")
include("selection.jl")
include("crossover.jl")
include("mutation.jl")
include("../plotter/plots.jl")

HCP = load_home_care_problem("/home/giorgiomelch/BI_AI/workspace/genetic-algorithm/Home_Care_Problem/data/train_0.json")


population = knn_initialize_population(HCP, 1)
update_population_fitness!(population, HCP)

print_individual_routes(population.individuals[1])
mutation_shift!(population.individuals[1], 1)
println("--------------------")
print_individual_routes(population.individuals[1])
println("--------------------")
println("--------------------")
println("--------------------")
println("--------------------")
println("--------------------")

function funz(population, HCP)
    println("funz")
    for i in 1:100
        mutation_shift!(population.individuals[1], 1)
        update_population_fitness!(population, HCP)
    end
    print_individual_routes(population.individuals[1])
end
funz(population, HCP)