include("fitness_function.jl")
include("./algorithms/_initialization.jl")
include("./algorithms/_selection.jl")
include("./algorithms/_crossover.jl")
include("./algorithms/_mutation.jl")
include("./algorithms/Simple_Genetic_Algorithm.jl")

using CSV, DataFrames, Random, Statistics

winequality_white_data_path = joinpath(@__DIR__, "..", "data", "winequality-white.csv")
df = CSV.read(winequality_white_data_path, DataFrame; header=true, delim=';')
X = Matrix(select(df, Not(last(names(df)))))
y = df[!, last(names(df))]  

simple_genetic_algorithm(X, y, 15, 20, 0.8)