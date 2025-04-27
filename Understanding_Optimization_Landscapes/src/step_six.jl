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
    "heart"   => "processed_cleveland",
    "zoo"     => "zoo",
    "letters" => "letter_recognition",
)
selected_dataset = dataset_names["letters"]
data_path = joinpath(@__DIR__, "..", "data", selected_dataset * ".csv")

# LOAD DATASET
df = CSV.read(data_path, DataFrame; header=true, delim=';')
X = Matrix(select(df, Not(last(names(df)))))
y = df[!, last(names(df))]  
number_of_features = size(X, 2)

# RUN BIOLOGICAL ALGORITHMS
N_RUNS = 4
N_POP = 20
N_ITERATIONS = 30

function run_algorithm(algorithm_function::Function, algorithm_name::String, lookup_table, num_features, N_POP, N_ITERATIONS, params...)
    Threads.@threads for i in 1:N_RUNS
        best_fitness, best_individual, _ = algorithm_function(lookup_table, num_features, N_POP, N_ITERATIONS, params..., -5)
        println("$algorithm_name: accuracy=", evaluate_individual_step_six(best_individual, X, y), 
                ", fitness=", best_fitness, 
                ", features used=", best_individual)
    end
end


run_algorithm(simple_genetic_algorithm, "SGA", [], number_of_features, N_POP, N_ITERATIONS, 0.8)
#run_algorithm(NSGA2, "NSGA2", [], number_of_features, N_POP, N_ITERATIONS, 0.8)
#run_algorithm(particle_swarm_optimization, "PSO", [], number_of_features, N_POP, N_ITERATIONS, 0.9, 2.0, 2.0, 2.0, 2)