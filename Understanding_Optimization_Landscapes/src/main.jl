include("fitness_function.jl")
include("lookup_table_manager.jl")
include("./algorithms/Simple_Genetic_Algorithm.jl")
include("./algorithms/NSGA2.jl")
include("./algorithms/Particle_Swarm_Optimization.jl")

using CSV, DataFrames, Random, Statistics

# -------------------------------------------------------------------------
# DATASET
# -------------------------------------------------------------------------
dataset_names = Dict(
    "wine"    => "winequality-white",
    "obesity" => "ObesityDataSet_raw_and_data_sinthetic",
    "magic"   => "magic04",
    "magic_r"   => "magic04_redundancy",
    "heart"   => "processed_cleveland",
    "zoo"     => "zoo",
)
selected_dataset = dataset_names["obesity"]
data_path = joinpath(@__DIR__, "..", "data", selected_dataset * ".csv")

# LOAD DATASET
df = CSV.read(data_path, DataFrame; header=true, delim=';')
X = Matrix(select(df, Not(last(names(df)))))

y = df[!, last(names(df))]  
number_of_features = size(X, 2)

# --------------------------------------------------letter-recognitiond.csv
# -------------------------------------------------------------------------
# Commented because it takes a lot of time
# CREATE LOOKUP TABLE
#create_lookup_table(X, y, 16, "ObesityDataSet_raw_and_data_sinthetic.jls")
#create_lookup_table(X, y, 11, "winequality-white.jls")
#create_lookup_table(X, y, 10, "magic04.jls")
#create_lookup_table(X, y, 15, "magic04_redundancy.jls")
#create_lookup_table(X, y, 16, "letter_recognition.jls")
# LOAD LOOKUP TABLE
lookup_table = load_lookup_table(selected_dataset * ".jls")
# -------------------------------------------------------------------------
# BENCHMARK TO REACH
# -------------------------------------------------------------------------
# SHOW THE BEST ACHIEVABLE ACCURACY 
best_accuracy = maximum(lookup_table)
best_idx = findall(x -> x == best_accuracy, lookup_table)[1]
best_features_bin = reverse(digits(best_idx, base=2))
best_features_bin = vcat(best_features_bin, zeros(Int, number_of_features - length(best_features_bin)))
println("Best ACCURACY: ", best_accuracy, ", Best features: ", best_features_bin)
# SHOW THE BEST ACHIEVABLE FITNESS
problem_best_fitness, problem_best_features = find_best_fitness(lookup_table, number_of_features)
println("Best FITNESS:  ", problem_best_fitness, ", with features: ", problem_best_features)
println("--------------------------------------------------------------------------------------------\n")

# RUN BIOLOGICAL ALGORITHMS
N_RUNS = 100
N_POP = 20
N_ITERATIONS = 30

function run_algorithm(algorithm_function::Function, algorithm_name::String, lookup_table, num_features, N_POP, N_ITERATIONS, params...)
    best_fitness_history = Float64[]
    convergence_speeds = Float64[]
    for i in 1:N_RUNS
        best_fitness, best_individual, convergence = algorithm_function(lookup_table, num_features, N_POP, N_ITERATIONS, params..., problem_best_fitness)
        accuracy = lookup_table[features_to_index(best_individual)]
        println("$algorithm_name: accuracy=", accuracy, 
                ", fitness=", best_fitness, 
                ", features used=", best_individual)
        push!(best_fitness_history, best_fitness)
        push!(convergence_speeds, convergence)
    end
    # STATS
    success_rate = count(x -> x != Inf, convergence_speeds)
    println("$algorithm_name: Success rate = $success_rate / $N_RUNS")
    
    convergence_speeds = filter(x -> x != Inf, convergence_speeds)
    if !isempty(convergence_speeds)
        mean_convergence = sum(convergence_speeds) / length(convergence_speeds)
        println("$algorithm_name: Mean convergence Speed = $mean_convergence")
    end

    println("$algorithm_name: Mean Fitness = ", mean(best_fitness_history))
    println("$algorithm_name: Standard Deviation = ", std(best_fitness_history))
    println()
    return mean(best_fitness_history), mean(convergence_speeds)
end


run_algorithm(simple_genetic_algorithm, "SGA", lookup_table, number_of_features, N_POP, N_ITERATIONS, 0.8)
run_algorithm(NSGA2, "NSGA2", lookup_table, number_of_features, N_POP, N_ITERATIONS, 0.8)
run_algorithm(particle_swarm_optimization, "PSO", lookup_table, number_of_features, N_POP, N_ITERATIONS, 0.9, 2.0, 2.0, 2.0, 2)