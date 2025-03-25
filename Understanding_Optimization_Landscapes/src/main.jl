include("fitness_function.jl")
include("lookup_table_manager.jl")
include("./algorithms/Simple_Genetic_Algorithm.jl")
include("./algorithms/NSGA2.jl")

using CSV, DataFrames, Random, Statistics

# LOAD DATASET
winequality_white_data_path = joinpath(@__DIR__, "..", "data", "winequality-white.csv")
ObesityDataSet_raw_and_data_sinthetic_data_path = joinpath(@__DIR__, "..", "data", "ObesityDataSet_raw_and_data_sinthetic.csv")
online_shoppers_intention_data_path = joinpath(@__DIR__, "..", "data", "online_shoppers_intention.csv")

# CREATE LOOKUP TABLE - commented beacuse it takes a lot of time
#create_lookup_table(X, y, 16, "lookup_table_student_performance.jls")
#create_lookup_table(X, y, 16, "winequality_white_data_path.jls")
#create_lookup_table(X, y, 16, "ObesityDataSet_raw_and_data_sinthetic.jls")

# LOAD LOOKUP TABLE
lookup_table = load_lookup_table("ObesityDataSet_raw_and_data_sinthetic.jls")

df = CSV.read(ObesityDataSet_raw_and_data_sinthetic_data_path, DataFrame; header=true, delim=',')
X = Matrix(select(df, Not(last(names(df)))))
y = df[!, last(names(df))]  


@time simple_genetic_algorithm(lookup_table, 16, 10, 10, 0.8)
#@time NSGA2(X, y, lookup_table, 10, 5, 0.8)
