function initialize_population(pop_size::Int64, num_items::Int64)
    return rand(Bool, pop_size, num_items)
end