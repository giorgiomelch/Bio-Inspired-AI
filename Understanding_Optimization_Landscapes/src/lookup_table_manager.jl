using Serialization

function build_lookup_table(features_number::Int)
    total_combinations = 2^features_number
    lookup_table = Vector{Float64}(undef, total_combinations)
    for i in 1:(total_combinations)
        lookup_table[i] = -1.0
    end
    return lookup_table
end

function update_lookup_table!(lookup_table::Vector{Float64}, index::Int, new_value::Float64)
    if index < 1 || idx > length(lookup_table)
        error("Combinazione fuori range: l'indice calcolato è $index, mentre la tabella ha dimensione $(length(lookup_table))")
    end
    lookup_table[index] = new_value
    return lookup_table
end

function save_lookup_table(lookup_table::Vector{Float64}, filename::String)
    serialize(filename, lookup_table)
end

function load_lookup_table(filename::String)
    filepath = joinpath(@__DIR__, "lookup_tables", filename)
    return deserialize(filepath)
end
using Serialization

function save_lookup_table(lookup_table::Vector{Float64}, filename::String)
    save_dir = joinpath(@__DIR__, "lookup_tables")
    filepath = joinpath(save_dir, filename)
    serialize(filepath, lookup_table)
    println("Lookup table salvata in: ", filepath)
end
