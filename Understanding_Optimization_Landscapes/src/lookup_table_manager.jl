using Serialization
using Base.Threads
include("fitness_function.jl")

function build_lookup_table(features_number::Int)
    total_combinations = 2^features_number
    lookup_table = Vector{Float64}(undef, total_combinations)
    for i in 1:(total_combinations)
        lookup_table[i] = -1.0
    end
    return lookup_table
end

function save_lookup_table(lookup_table::Vector{Float64}, filename::String)
    serialize(filename, lookup_table)
end

function load_lookup_table(filename::String)
    filepath = joinpath(@__DIR__, "lookup_tables", filename)
    return deserialize(filepath)
end

function save_lookup_table(lookup_table::Vector{Float64}, filename::String)
    save_dir = joinpath(@__DIR__, "lookup_tables")
    filepath = joinpath(save_dir, filename)
    serialize(filepath, lookup_table)
    println("Lookup table salvata in: ", filepath)
end

function create_lookup_table(X, y, features_number::Int, filename::String)
    lookup_table = build_lookup_table(features_number)
    count = 0
    @threads for i in 1:(2^features_number - 1)
        features_used = [parse(Int, x) for x in string(i, base=2, pad=features_number)]
        accuracy = random_forest(features_used, X, y)
        index_lt = features_to_index(features_used)
        lookup_table[index_lt] = accuracy
        println("Iter n: ", count, "/", 2^features_number, " - i: ", i, "(", index_lt, ")", "features_used: ", features_used, ", accuracy: ", accuracy)
        count += 1
    end
    save_lookup_table(lookup_table, filename)
end