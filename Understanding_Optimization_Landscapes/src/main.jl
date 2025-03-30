include("fitness_function.jl")
include("lookup_table_manager.jl")
include("./algorithms/Simple_Genetic_Algorithm.jl")
include("./algorithms/NSGA2.jl")
include("./algorithms/Particle_Swarm_Optimization.jl")

using CSV, DataFrames, Random, Statistics

path1 = "winequality-white"
path2 = "ObesityDataSet_raw_and_data_sinthetic"
path3 = "magic04"
# LOAD DATASET
path = path2
data_path = joinpath(@__DIR__, "..", "data", path * ".csv")

# LOAD DATASET
df = CSV.read(data_path, DataFrame; header=true, delim=';')
X = Matrix(select(df, Not(last(names(df)))))
y = df[!, last(names(df))]  
number_of_features = size(X, 2)

# CREATE LOOKUP TABLE - commented because it takes a lot of time
#create_lookup_table(X, y, 16, "lookup_table_student_performance.jls")
#create_lookup_table(X, y, 11, "winequality-white.jls")
#create_lookup_table(X, y, 10, "magic04.jls")
# LOAD LOOKUP TABLE
lookup_table = load_lookup_table(path * ".jls")

# SHOW THE BEST ACHIEVABLE ACCURACY 
println("Best ACCURACY: ", maximum(lookup_table), ", Best features: ", reverse(digits(findall(x -> x == maximum(lookup_table), lookup_table)[1], base=2)))
# SHOW THE BEST ACHIEVABLE FITNESS
problem_best_fitness, problem_best_features = find_best_fitness(lookup_table, number_of_features)
println("Best FITNESS: ", problem_best_fitness, ", with features: ", problem_best_features)

# RUN BIOLOGICAL ALGORITHMS
best_fitness, best_individual = simple_genetic_algorithm(lookup_table, number_of_features, 20, 50, 0.8)
println("SGA:   accuracy=",lookup_table[features_to_index(best_individual)], ", fitness=", best_fitness, ", features used=",best_individual)

best_fitness, best_individual = NSGA2(lookup_table, number_of_features, 20, 50, 0.8)
println("NSGA2: accuracy=",lookup_table[features_to_index(best_individual)], ", fitness=", best_fitness, ", features used=",best_individual)

best_features, best_fitness = particle_swarm_optimization(20, number_of_features, 50, 0.7, 1.5, 1.5, lookup_table)
println("PSO:   accuracy=",lookup_table[features_to_index(best_individual)], ", fitness=", best_fitness, ", features used=",best_individual)
