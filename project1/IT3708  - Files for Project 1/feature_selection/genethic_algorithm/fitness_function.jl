function evaluate_population(pop::Matrix{Bool}, profits::Vector{Int64}, weights::Vector{Int64}, capacity::Int64)
    total_profit = pop * profits
    total_weight = pop * weights
    penalty = max.(0, total_weight .- capacity) # penalty only if total_weight > capacity
    return total_profit .- penalty, total_weight
end

function weighted_sum(fitness::Vector{Int64}, weights::Vector{Int64})
    return sum(fitness .* weights)
end