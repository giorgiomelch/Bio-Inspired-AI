include("fitness_function.jl")
include("lookup_table_manager.jl")
include("./algorithms/Simple_Genetic_Algorithm.jl")
include("./algorithms/NSGA2.jl")

using CSV, DataFrames, Random, Statistics

# LOAD DATASET
winequality_white_data_path = joinpath(@__DIR__, "..", "data", "winequality-white.csv")
ObesityDataSet_raw_and_data_sinthetic_data_path = joinpath(@__DIR__, "..", "data", "ObesityDataSet_raw_and_data_sinthetic.csv")
online_shoppers_intention_data_path = joinpath(@__DIR__, "..", "data", "online_shoppers_intention.csv")

# LOAD LOOKUP TABLE
lookup_table = load_lookup_table("ObesityDataSet_raw_and_data_sinthetic.jls")

df = CSV.read(ObesityDataSet_raw_and_data_sinthetic_data_path, DataFrame; header=true, delim=',')
X = Matrix(select(df, Not(last(names(df)))))
y = df[!, last(names(df))]  
# CREATE LOOKUP TABLE - commented beacuse it takes a lot of time
#create_lookup_table(X, y, 16, "lookup_table_student_performance.jls")
#create_lookup_table(X, y, 11, "winequality_white_data_path.jls")
#create_lookup_table(X, y, 16, "ObesityDataSet_raw_and_data_sinthetic.jls")


# BENCHMARK TO REACH
#println("Max accuracy: ", maximum(lookup_table), ", Best features: ", reverse(digits(findall(x -> x == maximum(lookup_table), lookup_table)[1], base=2)))

best_fitness, best_individual = simple_genetic_algorithm(lookup_table, 16, 10, 100, 1)
#best_fitness, best_individual = NSGA2(lookup_table, 16, 10, 100, 1)
println("RF: ",random_forest(best_individual, X, y))
println("LT: ",lookup_table[features_to_index(best_individual)])